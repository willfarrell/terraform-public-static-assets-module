# TODO
# add in x-ray https://docs.aws.amazon.com/xray/latest/devguide/xray-sdk-python.html
# get account id, store?, reuse - https://letsencrypt.org/docs/account-id/
#
# $ certbot register --agree-tos --email EMAIL
# $ certbot update_account
# $ certbot unregister --account ACCOUNT_ID
# Sign up for prod use: https://community.letsencrypt.org/t/ecdsa-availability-in-production-environment/150679
import boto3
import certbot.main
import datetime
import os
import subprocess

acm = boto3.client('acm')
sns = boto3.client('sns')

def read_and_delete_file(path):
    with open(path, 'r') as file:
        contents = file.read()
    os.remove(path)
    return contents

def provision_cert(domains, key_type, email):
    certbot.main.main([
        'certonly',                             # Obtain a cert but don't install it
        '-n',                                   # Run in non-interactive mode
        '--agree-tos',                          # Agree to the terms of service,
        '--email', email,                       # Email
        '--dns-route53',                        # Use dns challenge with route53
        '--domains', domains,                   # Domains to provision certs for
        '--key-types', key_type,                # Key type to use, rsa or ecdsa
        '--staging',
        # Override directory paths so script doesn't have to be run as root
        '--config-dir', '/tmp/config-dir',
        '--work-dir', '/tmp/work-dir',
        '--logs-dir', '/tmp/logs-dir',
    ])

    first_domain = domains.split(',')[0]
    path = '/tmp/config-dir/live/' + first_domain + '/'
    return {
        'certificate': read_and_delete_file(path + 'cert.pem'),
        'private_key': read_and_delete_file(path + 'privkey.pem'),
        'certificate_chain': read_and_delete_file(path + 'chain.pem')
    }

def should_provision(domains):
    existing_cert = find_existing_cert(domains)
    if existing_cert:
        now = datetime.datetime.now(datetime.timezone.utc)
        not_after = existing_cert['Certificate']['NotAfter']
        return (not_after - now).days <= 30
    else:
        return True

def find_existing_cert(domains):
    domains = frozenset(domains.split(','))

    paginator = acm.get_paginator('list_certificates')
    iterator = paginator.paginate(PaginationConfig={'MaxItems':1000})

    for page in iterator:
        for cert in page['CertificateSummaryList']:
            cert = client.describe_certificate(CertificateArn=cert['CertificateArn'])
            sans = frozenset(cert['Certificate']['SubjectAlternativeNames'])
            if sans.issubset(domains):
                return cert

    return None

def notify_via_sns(topic_arn, domains, certificate):
    process = subprocess.Popen(['openssl', 'x509', '-noout', '-text'],
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE, encoding='utf8')
    stdout, stderr = process.communicate(certificate)

    sns.publish(TopicArn=topic_arn,
                   Subject='Issued new LetsEncrypt certificate',
                   Message='Issued new certificates for domains: ' + domains + '\n\n' + stdout,
                   )

def upload_cert_to_acm(cert, domains):
    existing_cert = find_existing_cert(domains)
    certificate_arn = existing_cert['Certificate']['CertificateArn'] if existing_cert else None

    client = boto3.client('acm')
    if certificate_arn:
        acm_response = client.import_certificate(
            CertificateArn=certificate_arn,
            Certificate=cert['certificate'],
            PrivateKey=cert['private_key'],
            CertificateChain=cert['certificate_chain']
        )
    else:
        acm_response = client.import_certificate(
            Certificate=cert['certificate'],
            PrivateKey=cert['private_key'],
            CertificateChain=cert['certificate_chain']
        )

    return None if certificate_arn else acm_response['CertificateArn']

def handler(event, context):
    try:
        domains = event.domains
        if should_provision(domains):
            cert = provision_cert(domains, event['key-type'], event['email'])
            upload_cert_to_acm(cert, domains)
            # TODO Future
            #notify_via_sns(os.environ['NOTIFICATION_SNS_ARN'], domains, cert['certificate'])
    except:
        raise