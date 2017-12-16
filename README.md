# Terraform App Endpoint
Creates CloudFront (w/ WAF and Lambda) and S3 Bucket.

## Setup
### Requirements

- Edge provider in the root.

```hcl-terraform
provider "aws" {
    region  = "us-east-1"
    profile = "redcross"
    alias   = "edge"
}

```

-  ACM Certificate

```hcl-terraform
data "aws_acm_certificate" "main" {
  provider = "aws.edge"
  domain   = "${var.env}-appname.tesera.com"
  statuses = ["ISSUED"]
}
```

- Web Application Firewall (Optional)

```hcl-terraform
module "waf" {
  source = "github.com/tesera/terraform-owasp-waf-module"
  name   = "${var.env}ApplicationName"
  defaultAction = "${var.defaultAction}"

  ipAdminListId = "${var.ipAdminListId}"
  ipBlackListId = "${var.ipBlackListId}"
  ipWhiteListId = "${var.ipWhiteListId}"
}
```

### Module
```hcl-terraform
module "app" {
  source              = "github.com/tesera/terraform-s3-endpoint-module"
  env                 = "${var.env}"
  aws_account_id      = "${var.aws_account_id}"
  aws_region          = "${var.aws_region}"

  name                = "emis-registration-app"
  aliases             = ["${var.env != "prod" ? "${var.env}-": ""}appname.tesera.com"]
  acm_certificate_arn = "${data.aws_acm_certificate.main.arn}"
  web_acl_id          = "${module.waf.id}"
  lambda_edge_content = "${replace(file("${path.module}/edge.js"), "{pkphash}", "${var.pkphash}")}"
}
```

## Input
- **env:** Environment Name, typically `dev`,`uat`,`prod`.
- **aws\_account\_id:** AWS Account ID
- **aws_region:** AWS Region to deploy in
- **name:** AWS S3 Bucket name. `${var.env}-${var.name}`.
- **aliases:** CloudFront Aliases.
- **acm_certificate_arn:** Domain Certificate ARN
- **web_acl_id:** WAF ACL ID
- **lambda_edge_content:** By default this module includes a lambda function to add security headers to all responses. This can be overwritten using the above example.

## Output
- **bucket_name:** `${aws_s3_bucket.main.id}` Full name of the S3 bucket.
- **cloudfront_distribution_id:** `${aws_cloudfront_distribution.main.id}` CloudFront Distribution Id for CI/CD to trigger cache clearing (`aws cloudfront create-invalidation --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} --paths /index.html`)
- **cloudfront_distribution_domain_name:** `${aws_cloudfront_distribution.main.domain_name}` CloudFront Domain Name for DNS updating.
