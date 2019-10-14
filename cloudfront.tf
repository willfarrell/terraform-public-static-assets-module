resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${local.name} S3 static assets origin access policy"
}

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2"
  web_acl_id      = var.web_acl_id
  price_class     = var.price_class

  aliases = var.aliases

  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == ""
    acm_certificate_arn            = var.acm_certificate_arn
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }

  origin {
    domain_name = local.bucket_domain_name
    origin_id   = "www"
    origin_path = var.origin_path

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = "www"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    cached_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    viewer_protocol_policy = "redirect-to-https"

    compress = var.compress
    min_ttl                = 0
    default_ttl            = 86400
    # 1d
    max_ttl                = 31536000
    # 1y

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

      headers = var.forward_headers
    }

    dynamic "lambda_function_association" {
      for_each = keys(var.lambda)
      content {
        event_type = lambda_function_association.value
        lambda_arn = aws_lambda_function.lambda[lambda_function_association.key].qualified_arn
      }
    }
  }


  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = origin.value.origin_path

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"

        origin_ssl_protocols = [
          "TLSv1.2",
        ]
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.origins
    content {
      target_origin_id = ordered_cache_behavior.value.origin_id
      path_pattern     = "${ordered_cache_behavior.value.path_pattern}/*"

      allowed_methods = ordered_cache_behavior.value.allowed_methods
      cached_methods = ordered_cache_behavior.value.cached_methods

      viewer_protocol_policy = "redirect-to-https"
      #trusted_signers = ordered_cache_behavior.value.trusted_signers  #  The AWS accounts, if any, that you want to allow to create signed URLs for private content.

      compress    = var.compress
      min_ttl     = 0
      default_ttl = 86400
      # 1d
      max_ttl     = 31536000
      # 1y

      forwarded_values {
        query_string = ordered_cache_behavior.value.query_string
        query_string_cache_keys = ordered_cache_behavior.value.query_string_cache_keys

        headers = ordered_cache_behavior.value.headers

        cookies {
          forward = "none"
        }
      }

      /*dynamic "lambda_function_association" {
        for_each = keys(ordered_cache_behavior.value.lambda)
        content {
          event_type = lambda_function_association.value
          lambda_arn = aws_lambda_function.lambda[lambda_function_association.key].qualified_arn
        }
      }*/
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_root_object = var.default_root_object

  dynamic "custom_error_response" {
    for_each = var.error_codes == "" ? {} : var.error_codes
    content {
      error_code         = custom_error_response.key
      response_code      = 200
      response_page_path = custom_error_response.value
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${local.logging_bucket}.s3.amazonaws.com"
    prefix          = "AWSLogs/${local.account_id}/CloudFront/${var.aliases[0]}/"
  }

  tags = merge(
  local.tags,
  {
    Name = "${local.name} CloudFront"
  }
  )
}

