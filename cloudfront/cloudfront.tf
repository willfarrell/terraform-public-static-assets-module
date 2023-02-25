resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${var.aliases[0]}"
}

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  web_acl_id      = var.web_acl_id
  price_class     = var.price_class

  aliases = var.aliases

  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == ""
    acm_certificate_arn            = var.acm_certificate_arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = origin.value.origin_path

      dynamic "s3_origin_config" {
        for_each = origin.value.type == "s3" ? [1] : []
        content {
          origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
        }
      }
      dynamic "custom_origin_config" {
        for_each = origin.value.type == "custom" ? [1] : []
        content {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"

          origin_ssl_protocols = [
            "TLSv1.2",
          ]
        }
      }
      dynamic "origin_shield" {
        for_each = origin.value.origin_shield != "disabled" ? [1] : []
        content {
          enabled = true
          origin_shield_region = origin.value.origin_shield
        }
      }
      
      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }
  
  dynamic "origin_group" {
    for_each = var.origin_groups
    content {
      origin_id = origin_group.value.origin_id
      failover_criteria {
        status_codes = origin_group.value.status_codes
      }
      dynamic "member" {
        for_each = origin_group.value.origin_ids
        content {
          origin_id = member.value
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = slice(var.behaviors, 0, length(var.behaviors)-1) # all except last item
    content {
      target_origin_id = ordered_cache_behavior.value.origin_id
      path_pattern     = ordered_cache_behavior.value.path_pattern
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = try(ordered_cache_behavior.value.allowed_methods, [])

      #trusted_signers = ordered_cache_behavior.value.trusted_signers  #  The AWS accounts, if any, that you want to allow to create signed URLs for private content.

      # Broken out on purpose to prevent state issues (re-creating edge@lambda when index changes)
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda.viewer-request != null ? [1] : []
        content {
          event_type = "viewer-request"
          lambda_arn = ordered_cache_behavior.value.lambda.viewer-request
        }
      }
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda.origin-request != null? [1] : []
        content {
          event_type = "origin-request"
          lambda_arn = ordered_cache_behavior.value.lambda.origin-request
        }
      }
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda.origin-response != null ? [1] : []
        content {
          event_type = "origin-response"
          lambda_arn = ordered_cache_behavior.value.lambda.origin-response
        }
      }
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda.viewer-response != null ? [1] : []
        content {
          event_type = "viewer-response"
          lambda_arn = ordered_cache_behavior.value.lambda.viewer-response
        }
      }
      
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id
      cached_methods = ordered_cache_behavior.value.cached_methods
      cache_policy_id = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id = ordered_cache_behavior.value.origin_request_policy_id
      #compress = ordered_cache_behavior.value.compress
    }
  }
  
  dynamic "default_cache_behavior" {
    for_each = slice(var.behaviors, length(var.behaviors)-1, length(var.behaviors)) # Last item
    content {
      target_origin_id = default_cache_behavior.value.origin_id
      viewer_protocol_policy = "redirect-to-https"
      
      allowed_methods = try(default_cache_behavior.value.allowed_methods, [])
      
      #trusted_signers = ordered_cache_behavior.value.trusted_signers  #  The AWS accounts, if any, that you want to allow to create signed URLs for private content.
      
      # Broken out on purpose to prevent state issues (re-creating edge@lambda when index changes)
      dynamic "lambda_function_association" {
        for_each = default_cache_behavior.value.lambda.viewer-request != null ? [1] : []
        content {
          event_type = "viewer-request"
          lambda_arn = default_cache_behavior.value.lambda.viewer-request
        }
      }
      dynamic "lambda_function_association" {
        for_each = default_cache_behavior.value.lambda.origin-request != null ? [1] : []
        content {
          event_type = "origin-request"
          lambda_arn = default_cache_behavior.value.lambda.origin-request
        }
      }
      dynamic "lambda_function_association" {
        for_each = default_cache_behavior.value.lambda.origin-response != null ? [1] : []
        content {
          event_type = "origin-response"
          lambda_arn = default_cache_behavior.value.lambda.origin-response
        }
      }
      dynamic "lambda_function_association" {
        for_each = default_cache_behavior.value.lambda.viewer-response != null ? [1] : []
        content {
          event_type = "viewer-response"
          lambda_arn = default_cache_behavior.value.lambda.viewer-response
        }
      }
      
      origin_request_policy_id = default_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = default_cache_behavior.value.response_headers_policy_id
      cached_methods = default_cache_behavior.value.cached_methods
      cache_policy_id = default_cache_behavior.value.cache_policy_id
      #compress = default_cache_behavior.value.compress
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


