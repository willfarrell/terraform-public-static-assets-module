resource "aws_cloudfront_response_headers_policy" "main" {
  name    = var.name
  #comment = "Security headers"

  cors_config {
    access_control_allow_credentials = var.cors.access_control_allow_credentials
    access_control_allow_headers {
      items = var.cors.access_control_allow_headers
    }
    access_control_allow_methods {
      items = var.cors.access_control_allow_methods
    }
    access_control_allow_origins {
      items = var.cors.access_control_allow_origins
    }
    origin_override = var.cors.override
  }

  security_headers_config {
    
    # Strict-Transport-Security: max-age=63072000; includeSubdomains; preload
    strict_transport_security {
      access_control_max_age_sec = var.strict_transport_security.access_control_max_age_sec
      include_subdomains         = var.strict_transport_security.include_subdomains
      preload                    = var.strict_transport_security.preload
      override                   = var.strict_transport_security.override
    }
    
    # Content-Security-Policy
    dynamic "content_security_policy" {
      for_each = contains(var.mimes, "text/html") || contains(var.mimes, "application/javascript") ? [1] : []
      content {
        content_security_policy = var.content_security.policy
        override = var.content_security.override
      }
    }
    # X-Content-Type-Options: nosniff
    dynamic "content_type_options" {
      for_each = contains(var.mimes, "text/html") ? [1] : []
      content {
        override = var.content_type_options.override
      }
    }
    # X-Frame-Options: DENY
    dynamic "frame_options" {
      for_each = contains(var.mimes, "text/html") ? [1] : []
      content {
        frame_option = var.frame_options.frame_option
        override     = var.frame_options.override
      }
    }
    # Referrer-Policy: no-referrer
    dynamic "referrer_policy" {
      for_each = contains(var.mimes, "text/html") ? [1] : []
      content {
        referrer_policy = var.referrer.policy
        override        = var.referrer.override
      }
    }
    # X-XSS-Protection: 1; mode=block
    dynamic "xss_protection" {
      for_each = contains(var.mimes, "text/html") ? [1] : []
      content {
        mode_block = var.xss_protection.mode_block
        protection = var.xss_protection.protection
        override   = var.xss_protection.override
      }
    }
  }
  
  server_timing_headers_config {
    enabled       = var.server_timing.sample_rate != 0
    sampling_rate = var.server_timing.sample_rate
  }
  
  # remove_headers_config {
  #   items {
  #     header   = "Server"
  #   }
  #   
  #   dynamic "items" {
  #     for_each = var.remove_headers
  #     content {
  #       header   = items.value.header
  #     }
  #   }
  # }
  # TODO make conditional
  dynamic "remove_headers_config" {
    for_each = length(var.remove_headers) > 0 ? [1] : []
    content {
      dynamic "items" {
        for_each = var.remove_headers
        content {
          header   = items.value.header
        }
      }
    }
  }
  
  dynamic "custom_headers_config" {
    for_each = contains(var.mimes, "text/html") || contains(var.mimes, "application/javascript") || length(var.custom_headers) > 0 ? [1] : []
    content {
      
      /*
      
      items {
        header   = "via"
        value    = "_"
        override = true
      }
      items {
        header   = "x-amz-cf-id"
        value    = "_"
        override = true
      }
      items {
        header   = "x-amz-cf-pop"
        value    = "_"
        override = true
      }
      x-amzn-requestid
      x-amzn-trace-id
      
      
      */
      /*items {
        header   = "Timing-Allow-Origin"
        value    = "https://${local.workspace["main_domain"]}"
        override = true
      }*/
      
      dynamic "items" {
        for_each = contains(var.mimes, "text/html") ? [1] : []
        content {
          header = "NEL"
          value = jsonencode({
            "report_to" : var.nel.report_to,
            "max_age" : var.nel.max_age,
            "include_subdomains" : var.nel.include_subdomains
          })
          override = var.nel.override
        }
      }
  
      # https://www.permissionspolicy.com/
      # https://github.com/w3c/webappsec-permissions-policy/blob/main/features.md
      dynamic "items" {
        for_each = contains(var.mimes, "text/html") || contains(var.mimes, "application/javascript") ? [1] : []
        content {
          header = "Permissions-Policy"
          value = var.permissions.policy
          override = var.permissions.override
        }
      }
      
      dynamic "items" {
        for_each = contains(var.mimes, "text/html") || contains(var.mimes, "application/javascript") ? [1] : []
        content {
          header = "Report-To"
          value = join(",", [
            jsonencode({
              "group" : "default",
              "max_age" : 31536000,
              "endpoints" : [{ "url" : "https://${var.report_to.id}.report-uri.com/a/d/g" }],
              "include_subdomains" : true
            }),
            jsonencode({ "group" : "csp", "max-age" : 10886400, "endpoints" : [{ "url" : "https://${var.report_to.id}.report-uri.com/r/d/csp/enforce" }] }),
            #jsonencode({ "group": "hpkp", "max-age": 10886400, "endpoints": [ { "url": "https://${var.report_to.id}.report-uri.com/r/d/hpkp/enforce" } ] }), # Deprecated
            #jsonencode({ "group": "ct", "max-age": 10886400, "endpoints": [ { "url": "https://${var.report_to.id}.report-uri.com/r/d/ct/enforce" } ] }), # Deprecated
            jsonencode({ "group" : "staple", "max-age" : 10886400, "endpoints" : [{ "url" : "https://${var.report_to.id}.report-uri.com/r/d/staple/enforce" }] }),
            jsonencode({ "group" : "xss", "max-age" : 10886400, "endpoints" : [{ "url" : "https://${var.report_to.id}.report-uri.com/r/d/xss/enforce" }] })
          ])
          override = var.report_to.override
        }
      }
      
      dynamic "items" {
        for_each = contains(var.mimes, "text/html") ? [1] : []
        content {
          header   = "Cross-Origin-Embedder-Policy"
          value    = var.coep.policy
          override = var.coep.override
        }
      }
      dynamic "items" {
        for_each = contains(var.mimes, "text/html") ? [1] : []
        content {
          header   = "Cross-Origin-Opener-Policy"
          value    = var.coop.policy
          override = var.coop.override
        }
      }
      dynamic "items" {
        for_each = contains(var.mimes, "text/html") ? [1] : []
        content {
          header   = "Cross-Origin-Resource-Policy"
          value    = var.corp.policy
          override = var.corp.override
        }
      }
      
      dynamic "items" {
        for_each = var.custom_headers
        content {
          header   = items.value.header
          value    = items.value.value
          override = items.value.override
        }
      }
    }
  }
}
