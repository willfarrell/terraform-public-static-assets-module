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
    access_control_max_age_sec = var.cors.access_control_max_age_sec
    origin_override = var.cors.override
  }

  security_headers_config {
    
    dynamic "content_security_policy" {
      for_each = var.content_security_policy != null && contains(var.mimes, "text/html") ? [1] : []
      content {
        content_security_policy =  try("${var.content_security_policy.value};report-to=${var.content_security_policy.report_to};report-uri=${var.report_to.default}",null)
        override = try(var.content_security_policy.override, false)
      }
    }
    
    # Strict-Transport-Security: max-age=63072000; includeSubdomains; preload
    strict_transport_security {
      access_control_max_age_sec = var.strict_transport_security.access_control_max_age_sec
      include_subdomains         = var.strict_transport_security.include_subdomains
      preload                    = var.strict_transport_security.preload
      override                   = var.strict_transport_security.override
    }
    
    # Referrer-Policy: no-referrer
    dynamic "referrer_policy" {
      for_each = var.referrer_policy != null && contains(var.mimes, "text/html") ? [1] : []
      content {
        referrer_policy = try("${var.referrer_policy.value}",null)
        override = try(var.referrer_policy.override, false)
      }
    }
    
    # X-Content-Type-Options: nosniff
    dynamic "content_type_options" {
      for_each = var.x_content_type_options != null && contains(var.mimes, "text/html") ? [1] : []
      content {
        override = try(var.x_content_type_options.override, false)
      }
    }
    
    # X-Frame-Options: DENY
    dynamic "frame_options" {
      for_each =  var.x_frame_options != null  && contains(var.mimes, "text/html") ? [1] : []
      content {
        frame_option = try(var.x_frame_options.value,null)
        override     = try(var.x_content_type_options.override, false)
      }
    }
    
    # X-XSS-Protection: 1; mode=block
    # dynamic "xss_protection" {
    #   for_each = var.x_xss_protection != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     mode_block = var.x_xss_protection.mode_block
    #     protection = var.x_xss_protection.protection
    #     override   = var.x_xss_protection.override
    #   }
    # }
  }
  
  server_timing_headers_config {
    enabled       = var.server_timing.sampling_rate != 0
    sampling_rate = var.server_timing.sampling_rate
  }
  
  # Max of 10
  remove_headers_config {
    # items {
    #   header   = "Expect-CT"
    # }
    # items {
    #   header   = "Feature-Policy"
    # }
    # items {
    #   header   = "Public-Key-Pins"
    # }
    # items {
    #   header   = "Public-Key-Pins-Report-Only"
    # }
    # items {
    #   header   = "Server" # Not allowed
    # }
    # items {
    #   header   = "Tk"
    # }
    # items {
    #   header   = "X-Aspnet-Version"
    # }
    # items {
    #   header   = "X-Backend-Server"
    # }
    # items {
    #   header   = "X-Powered-By"
    # }
    # items {
    #   header   = "X-Server"
    # }
    # items {
    #   header   = "X-WebKit-CSP"
    # }
    items {
      header   = "X-XSS-Protection"
    }
    
    dynamic "items" {
      for_each = var.remove_headers
      content {
        header   = items.value.header
      }
    }
  }
  
  # Max of >12, disable -Report-Only
  custom_headers_config {
  
    # Move to remove, when allowed
    items {
      header   = "Server"
      value    = "_"
      override = true
    }
    /*items {
      header   = "Timing-Allow-Origin"
      value    = "https://${local.workspace["main_domain"]}"
      override = true
    }*/

    
    # Can be set using custom_headers, but can be set another way
    # dynamic "items" {
    #   for_each = var.content_security_policy != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "Content-Security-Policy"
    #     value    = try("${var.content_security_policy.value};report-to=${var.content_security_policy.report_to};report-uri=${var.report_to.default}",null)
    #     override = try(var.content_security_policy.override, false)
    #   }
    # }
    
    # dynamic "items" {
    #   for_each = var.content_security_policy_report_only != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "Content-Security-Policy-Report-Only"
    #     value    = try("${var.content_security_policy_report_only.value};report-to=${var.content_security_policy_report_only.report_to};report-uri=${var.report_to.default}",null)
    #     override = try(var.content_security_policy_report_only.override, false)
    #   }
    # }
    
    dynamic "items" {
      for_each = var.cross_origin_embedder_policy != null && contains(var.mimes, "text/html") ? [1] : []
      content {
        header   = "Cross-Origin-Embedder-Policy"
        value    = try("${var.cross_origin_embedder_policy.value};report-to=${var.cross_origin_embedder_policy.report_to}",null)
        override = try(var.cross_origin_embedder_policy.override, false)
      }
    }
    # dynamic "items" {
    #   for_each = var.cross_origin_embedder_policy_report_only != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "Cross-Origin-Embedder-Policy-Report-Only"
    #     value    = try("${var.cross_origin_embedder_policy_report_only.value};report-to=${var.cross_origin_embedder_policy_report_only.report_to}",null)
    #     override = try(var.cross_origin_embedder_policy_report_only.override, false)
    #   }
    # }
    dynamic "items" {
      for_each = var.cross_origin_opener_policy != null && contains(var.mimes, "text/html") ? [1] : []
      content {
        header   = "Cross-Origin-Opener-Policy"
        value    = try("${var.cross_origin_opener_policy.value};report-to=${var.cross_origin_opener_policy.report_to}",null)
        override = try(var.cross_origin_opener_policy.override, false)
      }
    }
    # dynamic "items" {
    #   for_each = var.cross_origin_opener_policy_report_only != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "Cross-Origin-Opener-Policy-Report-Only"
    #     value    = try("${var.cross_origin_opener_policy_report_only.value};report-to=${var.cross_origin_opener_policy_report_only.report_to}",null)
    #     override = try(var.cross_origin_opener_policy_report_only.override, false)
    #   }
    # }
    
    dynamic "items" {
      for_each = var.cross_origin_resource_policy != null && contains(var.mimes, "text/html") ? [1] : []
      content {
        header   = "Cross-Origin-Resource-Policy"
        value    = try("${var.cross_origin_resource_policy.value}",null)
        override = try(var.cross_origin_resource_policy.override, false)
      }
    }
    
    dynamic "items" {
      for_each = var.document_policy != null && contains(var.mimes, "text/html") ? [1] : []
      content {
        header   = "Document-Policy"
        value    = try("${var.document_policy.value},*;report-to=${var.document_policy.report_to}",null)
        override = try(var.document_policy.override, false)
      }
    }
    # dynamic "items" {
    #   for_each = var.document_policy_report_only != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "Document-Policy-Report-Only"
    #     value    = try("${var.document_policy_report_only.value},*;report-to=${var.document_policy_report_only.report_to}",null)
    #     override = try(var.document_policy_report_only.override, false)
    #   }
    # }
    
    dynamic "items" {
      for_each = var.integrity_policy != null && contains(var.mimes, "text/html") ? [1] : []
      content {
        header   = "Integrity-Policy"
        value    = try("${var.integrity_policy.value},endpoints=(${var.integrity_policy.report_to})",null)
        override = try(var.integrity_policy.override, false)
      }
    }
    # dynamic "items" {
    #   for_each = var.integrity_policy_report_only != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "Integrity-Policy-Report-Only"
    #     value    = try("${var.integrity_policy_report_only.value},endpoints(${var.integrity_policy_report_only.report_to})",null)
    #     override = try(var.integrity_policy_report_only.override, false)
    #   }
    # }
    
    dynamic "items" {
      for_each = var.network_error_logging != null && contains(var.mimes, "text/html") ? [1] : []
      content {
        header   = "NEL"
        value    = try(jsonencode({
          "max_age" : var.network_error_logging.max_age,
          "include_subdomains" : var.network_error_logging.include_subdomains,
          "failure_fraction": var.network_error_logging.failure_fraction,
          "report_to" : var.network_error_logging.report_to
        }),null)
        override = try(var.network_error_logging.override, false)
      }
    }

    dynamic "items" {
      for_each = var.permissions_policy != null && (contains(var.mimes, "text/html") || contains(var.mimes, "application/javascript")) ? [1] : []
      content {
        header   = "Permissions-Policy"
        value    = try("${var.permissions_policy.value}",null) # ,report-to=${var.permissions_policy.report_to} ignored
        override = try(var.permissions_policy.override, false)
      }
    }
    
    # dynamic "items" {
    #   for_each = var.permissions_policy_report_only != null && (contains(var.mimes, "text/html") || contains(var.mimes, "application/javascript")) ? [1] : []
    #   content {
    #     header   = "Permissions-Policy-Report-Only"
    #     value    = try("${var.permissions_policy_report_only.value}",null) # ,report-to=${var.permissions_policy_report_only.report_to} ignored
    #     override = try(var.permissions_policy_report_only.override, false)
    #   }
    # }
    
    # Cannot be set using custom_headers
    # dynamic "items" {
    #   for_each = var.referrer_policy != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "Referrer-Policy"
    #     value    = try("${var.referrer_policy.value}",null)
    #     override = try(var.referrer_policy.override, false)
    #   }
    # }
    
    dynamic "items" {
      for_each = var.report_to != null && (contains(var.mimes, "text/html") || contains(var.mimes, "application/javascript")) ? [1] : []
      content {
        header = "Report-To"
        value = try(join(",", [
          jsonencode({
            "group" : "default",
            "max_age" : 31536000,
            "endpoints" : [{ "url" : "${var.report_to.default}" }],
            "include_subdomains" : true
          }),
          # jsonencode({
          #   "group" : "backup",
          #   "max_age" : 31536000,
          #   "endpoints" : [{ "url" : "${var.report_to.backup}" }],
          #   "include_subdomains" : true
          # })
        ]),null)
        override = try(var.report_to.override, false)
      }
    }
    dynamic "items" {
      for_each = var.report_to != null && (contains(var.mimes, "text/html") || contains(var.mimes, "application/javascript")) ? [1] : []
      content {
        header = "Reporting-Endpoints"
        value  = try(join(",", [
          "default=\"${var.report_to.default}\"",
          # "backup=\"${var.report_to.backup}\""
        ]),null)
        override = try(var.report_to.override, false)
      }
    }
    
    # dynamic "items" {
    #   for_each = var.require_document_policy != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "Require-Document-Policy"
    #     value    = try("${var.require_document_policy.value},*;report-to=${var.require_document_policy.report_to}",null)
    #     override = try(var.require_document_policy.override, false)
    #   }
    # }
    
    # dynamic "items" {
    #   for_each = var.sec_required_document_policy != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "Sec-Required-Document-Policy"
    #     value    = try("${var.sec_required_document_policy.value},*;report-to=${var.sec_required_document_policy.report_to}",null)
    #     override = try(var.sec_required_document_policy.override, false)
    #   }
    # }
    
    # Cannot be set using custom_headers
    # dynamic "items" {
    #   for_each = var.x_content_type_options != null && contains(var.mimes, "text/html") ? [1] : []
    #   content {
    #     header   = "X-Content-Type-Options"
    #     value    = try(var.x_content_type_options.value,null)
    #     override = try(var.x_content_type_options.override, false)
    #   }
    # }
    
    # Cannot be set using custom_headers
    # dynamic "items" {
    #   for_each = var.x_frame_options != null ? [1] : []
    #   content {
    #     header   = "X-Frame-Options"
    #     value    = try(var.x_frame_options.value,null)
    #     override = try(var.x_frame_options.override, false)
    #   }
    # }
    
    dynamic "items" {
      for_each = var.x_permitted_cross_domain_policies != null ? [1] : []
      content {
        header   = "X-Permitted-Cross-Domain-Policies"
        value    = try(var.x_permitted_cross_domain_policies.value,null)
        override = try(var.x_permitted_cross_domain_policies.override, false)
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
