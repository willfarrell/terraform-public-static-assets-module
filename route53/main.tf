resource "aws_route53_zone" "main" {
  name = var.domain
}

# CloudWatch
resource "aws_route53_query_log" "main" {
  depends_on = [aws_cloudwatch_log_resource_policy.route53-query-logging-policy]

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.main.arn
  zone_id                  = aws_route53_zone.main.zone_id
}

data "aws_iam_policy_document" "main-logging" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "route53-query-logging-policy" {
  policy_name     = "${replace(var.domain, ".","_")}-route53-query-logging-policy"
  policy_document = data.aws_iam_policy_document.main-logging.json
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/route53/${aws_route53_zone.main.name}"
  retention_in_days = terraform.workspace == "production" ? 365 : 7
}

# CloudFront Alias
resource "aws_route53_record" "A" {
  count = length(keys(var.cloudfront))
  zone_id = aws_route53_zone.main.zone_id
  name    = "${keys(var.cloudfront)[count.index] == "" ? "" : "${keys(var.cloudfront)[count.index]}."}${var.domain}"
  type    = "A"
  alias {
    name = values(var.cloudfront)[count.index]
    zone_id = "Z2FDTNDATAQYW2"  # cloudfront.net
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "AAAA" {
  count = length(keys(var.cloudfront))
  zone_id = aws_route53_zone.main.zone_id
  name    = "${keys(var.cloudfront)[count.index] == "" ? "" : "${keys(var.cloudfront)[count.index]}."}${var.domain}"
  type    = "AAAA"
  alias {
    name = values(var.cloudfront)[count.index]
    zone_id = "Z2FDTNDATAQYW2"  // cloudfront.net
    evaluate_target_health = false
  }
}

# HTTPS / SVCB
resource "aws_route53_record" "HTTPS" {
  count = length(keys(var.https))
  zone_id = aws_route53_zone.main.zone_id
  name    = "${keys(var.https)[count.index] == "" ? "" : "${keys(var.https)[count.index]}."}${var.domain}"
  type    = "HTTPS"
  ttl     = "300"
  records = values(var.https)[count.index]
}

# Mail
resource "aws_route53_record" "MX" {
  count = length(keys(var.mx))
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain
  type    = "MX"
  ttl     = "300"
  records = values(var.mx)[count.index]
}

resource "aws_route53_record" "CNAME" {
  count = length(keys(var.cname))
  zone_id = aws_route53_zone.main.zone_id
  name    = "${keys(var.cname)[count.index] == "" ? "" : "${keys(var.cname)[count.index]}."}${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = values(var.cname)[count.index]
}

resource "aws_route53_record" "NS" {
  count = length(keys(var.ns))
  zone_id = aws_route53_zone.main.zone_id
  name    = "${keys(var.ns)[count.index] == "" ? "" : "${keys(var.ns)[count.index]}."}${var.domain}"
  type    = "NS"
  ttl     = "300"
  records = values(var.ns)[count.index]
}

# resource "aws_route53_record" "HTTPS" {
#   count   = 1
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.domain
#   type    = "HTTPS"
#   ttl     = "300"
#   records = "alpn=\"h3,h2\"" # ipv4hint=\"192.0.2.1\" ipv6hint=\"2001:db8::1\"
# }

# Security
resource "aws_route53_record" "CAA" {
  count = local.is_root ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain
  type    = "CAA"
  ttl     = "300"
  records = [
    "0 issue \"amazonaws.com\"",
    "128 issue \"letsencrypt.org\""
  ]
}

resource "aws_route53_record" "TXT" {
  count = length(keys(var.txt))
  zone_id = aws_route53_zone.main.zone_id
  name    = "${keys(var.txt)[count.index] == "" ? "" : "${keys(var.txt)[count.index]}."}${var.domain}"
  type    = "TXT"
  ttl     = "300"
  records = values(var.txt)[count.index]
}

# DNSSEC + DNSKEY + DS
resource "aws_route53_key_signing_key" "main" {
  count = local.is_root ? 1 : 0
  hosted_zone_id             = aws_route53_zone.main.id
  key_management_service_arn = var.key_management_service_arn
  name                       = var.domain
}

resource "aws_route53_hosted_zone_dnssec" "main" {
  count = local.is_root ? 1 : 0
  depends_on = [
    aws_route53_key_signing_key.main
  ]
  hosted_zone_id = aws_route53_key_signing_key.main[0].hosted_zone_id
}

//resource "aws_route53_record" "DNSKEY" {
//  count = local.is_root ? 1 : 0
//  zone_id = aws_route53_zone.main.zone_id
//  name    = var.domain
//  type    = "DNSKEY"
//  ttl     = "300"
//  records = [aws_route53_key_signing_key.main[0].dnskey_record]
//}

//resource "aws_route53_record" "DS" {
//  count = local.is_root ? 1 : 0
//  zone_id = aws_route53_zone.main.zone_id
//  name    = var.domain
//  type    = "DS"
//  ttl     = "300"
//  records = [aws_route53_key_signing_key.main[0].ds_record]
//}