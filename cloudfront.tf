resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${local.name} S3 static assets origin access policy"
}

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2"
  web_acl_id      = var.web_acl_id

  aliases = var.aliases

  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == ""
    acm_certificate_arn            = var.acm_certificate_arn
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }

  origin {
    origin_id   = local.name
    domain_name = aws_s3_bucket.main.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = local.name

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400

    # 1d
    max_ttl = 31536000

    # 1y
    compress = true

    forwarded_values {
      query_string = false

      # TODO add in headers here

      cookies {
        forward = "none"
      }
    }

    dynamic "lambda_function_association" {
      iterator = lambda_arn
      for_each = var.lambda_viewer_request == "" ? [] : list(aws_lambda_function.viewer_request[0].qualified_arn)
      content {
        event_type = "viewer-request"
        lambda_arn = lambda_arn.value
      }
    }

    dynamic "lambda_function_association" {
      iterator = lambda_arn
      for_each = var.lambda_origin_request == "" ? [] : list(aws_lambda_function.origin_request[0].qualified_arn)
      content {
        event_type = "origin-request"
        lambda_arn = lambda_arn.value
      }
    }

    dynamic "lambda_function_association" {
      iterator = lambda_arn
      for_each = var.lambda_origin_response == "" ? [] : list(aws_lambda_function.origin_response[0].qualified_arn)
      content {
        event_type = "origin-response"
        lambda_arn = lambda_arn.value
      }
    }

    dynamic "lambda_function_association" {
      iterator = lambda_arn
      for_each = var.lambda_viewer_response == "" ? [] : list(aws_lambda_function.viewer_response[0].qualified_arn)
      content {
        event_type = "viewer-response"
        lambda_arn = lambda_arn.value
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_root_object = "index.html"

  # TODO make variable
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/index.html"
  }

  logging_config {
    include_cookies = false
    bucket          = "${local.logging_bucket}.s3.amazonaws.com"
    prefix          = "AWSLogs/${local.account_id}/CloudFront/${var.aliases[0]}/"
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${local.name} CloudFront"
    },
  )
}

