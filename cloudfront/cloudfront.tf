resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${var.aliases[0]} S3 static assets origin access policy"
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
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  /*origin_group {
    origin_id = "group"
    failover_criteria {
      status_codes = [500]
    }
    member {
      origin_id = "www"
    }

    member {
      origin_id = "fallback"
    }
  }*/

  origin {
    domain_name = local.bucket_domain_name
    origin_id   = "www"
    origin_path = var.origin_path

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  /*origin {
    domain_name = local.bucket_domain_name
    origin_id   = "fallback"
    origin_path = var.fallback_path

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }*/

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
    response_headers_policy_id = var.response_headers_policy_id

    compress               = var.compress
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

      headers = var.forward_headers
    }

    dynamic "lambda_function_association" {
      for_each = can(var.lambda["viewer-request"]) ? [1] : []
      content {
        event_type = "viewer-request"
        lambda_arn = var.lambda["viewer-request"]
      }
    }
    dynamic "lambda_function_association" {
      for_each = can(var.lambda["origin-request"]) ? [1] : []
      content {
        event_type = "origin-request"
        lambda_arn = var.lambda["origin-request"]
      }
    }
    dynamic "lambda_function_association" {
      for_each = can(var.lambda["origin-response"]) ? [1] : []
      content {
        event_type = "origin-response"
        lambda_arn = var.lambda["origin-response"]
      }
    }
    dynamic "lambda_function_association" {
      for_each = can(var.lambda["viewer-response"]) ? [1] : []
      content {
        event_type = "viewer-response"
        lambda_arn = var.lambda["viewer-response"]
      }
    }
  }

  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = origin.value.origin_path

      dynamic "s3_origin_config" {
        for_each = try(origin.value.type, "custom") == "s3" ? [1] : []
        content {
          origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
        }
      }
      dynamic "custom_origin_config" {
        for_each = try(origin.value.type, "custom") == "custom" ? [1] : []
        content {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"

          origin_ssl_protocols = [
            "TLSv1.2",
          ]
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.origins
    content {
      target_origin_id = ordered_cache_behavior.value.origin_id
      path_pattern     = ordered_cache_behavior.value.path_pattern

      allowed_methods = try(ordered_cache_behavior.value.allowed_methods, [])
      cached_methods = try(ordered_cache_behavior.value.cached_methods, [])

      viewer_protocol_policy = "redirect-to-https"
      response_headers_policy_id = try(ordered_cache_behavior.value.response_headers_policy_id, null)
      #trusted_signers = ordered_cache_behavior.value.trusted_signers  #  The AWS accounts, if any, that you want to allow to create signed URLs for private content.

      compress    = can(ordered_cache_behavior.value.compress) ? ordered_cache_behavior.value.compress : false//try(ordered_cache_behavior.value.compress, false)
      min_ttl     = try(ordered_cache_behavior.value.min_ttl, 0)
      default_ttl = try(ordered_cache_behavior.value.default_ttl, 86400)
      max_ttl     = try(ordered_cache_behavior.value.max_ttl, 31536000)
      forwarded_values {
        query_string = try(ordered_cache_behavior.value.query_string, false)
        query_string_cache_keys = try(ordered_cache_behavior.value.query_string_cache_keys, [])

        headers = try(ordered_cache_behavior.value.headers, [])

        cookies {
          forward = "none"
        }
      }

      dynamic "lambda_function_association" {
        for_each = can(ordered_cache_behavior.value.lambda["viewer-request"]) ? [1] : []
        content {
          event_type = "viewer-request"
          lambda_arn = ordered_cache_behavior.value.lambda["viewer-request"]
        }
      }
      dynamic "lambda_function_association" {
        for_each = can(ordered_cache_behavior.value.lambda["origin-request"]) ? [1] : []
        content {
          event_type = "origin-request"
          lambda_arn = ordered_cache_behavior.value.lambda["origin-request"]
        }
      }
      dynamic "lambda_function_association" {
        for_each = can(ordered_cache_behavior.value.lambda["origin-response"]) ? [1] : []
        content {
          event_type = "origin-response"
          lambda_arn = ordered_cache_behavior.value.lambda["origin-response"]
        }
      }
      dynamic "lambda_function_association" {
        for_each = can(ordered_cache_behavior.value.lambda["viewer-response"]) ? [1] : []
        content {
          event_type = "viewer-response"
          lambda_arn = ordered_cache_behavior.value.lambda["viewer-response"]
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction
    }
  }

  default_root_object = var.default_root_object

  dynamic "custom_error_response" {
    for_each = var.error_codes
    content {
      error_code         = custom_error_response.key
      response_code      = custom_error_response.key
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

