variable "name" {
  type        = string
  description = "{env}-{name}"
}

variable "mimes" {
  description = "apply default for common types: html, js"
  type = list(string)
  default = []
}

## OPTIONS
variable "cors" {
  type = object({
    access_control_allow_credentials = optional(bool, false)
    access_control_allow_headers =  optional(list(string), ["*"])
    access_control_allow_methods = optional(list(string), ["HEAD"])
    access_control_allow_origins = optional(list(string), [""])
    access_control_max_age_sec = optional(number, 300)
    override = optional(bool, true)
  })
  default = {}
}

# All
variable "report_to" {
  description = "URL Reporting API sends to"
  type        = object({
    default   = optional(string, "https://example.com.report-to.org")
    backup    = optional(string, "https://example.com.report-to.xyz") # disabled
    override  = optional(bool, true)
  })
  default     = {}
}

variable "content_security_policy" {
  type        = object({
    value    = optional(string, "default-src 'none' 'report-sample';base-uri 'none';connect-src 'none';form-action 'none';frame-ancestors 'none';upgrade-insecure-requests;trusted-types 'none';require-trusted-types-for 'script'")
    report_to = optional(string, "default")
    override  = optional(bool, true)
  })
  default     = {}
}

variable "content_security_policy_report_only" {
  type        = object({
    value    = optional(string, "default-src 'none' 'report-sample';base-uri 'none';connect-src 'none';form-action 'none';frame-ancestors 'none';upgrade-insecure-requests;trusted-types 'none';require-trusted-types-for 'script'")
    report_to = optional(string, "default")
    override  = optional(bool, true)
  })
  default     = {}
}

variable "cross_origin_embedder_policy" {
  type = object({
    value = optional(string, "require-corp")
    report_to = optional(string, "default") # Always default
    override = optional(bool, true)
  })
  default = {}
}
variable "cross_origin_embedder_policy_report_only" {
  type = object({
    value = optional(string, "require-corp")
    report_to = optional(string, "default") # Always default
    override = optional(bool, true)
  })
  default = {}
}

variable "cross_origin_opener_policy" {
  type = object({
    value = optional(string, "same-origin")
    report_to = optional(string, "default") # Always default
    override = optional(bool, true)
  })
  default = {}
}

variable "cross_origin_opener_policy_report_only" {
  type = object({
    value = optional(string, "same-origin")
    report_to = optional(string, "default") # Always default
    override = optional(bool, true)
  })
  default = {}
}

variable "cross_origin_resource_policy" {
  type = object({
    value = optional(string, "same-origin")
    #report_to = optional(string, "default") # not supported
    override = optional(bool, true)
  })
  default = {}
}

variable "document_policy" {
  type = object({
    value = optional(string, "")
    report_to = optional(string, "default")
    override = optional(bool, true)
  })
  default = {}
}

variable "document_policy_report_only" {
  type = object({
    value = optional(string, "")
    report_to = optional(string, "default")
    override = optional(bool, true)
  })
  default = {}
}

variable "integrity_policy" {
  type = object({
    value = optional(string, "blocked-destinations=(script),sources=(inline)")
    report_to = optional(string, "default")
    override = optional(bool, true)
  })
  default = {}
}

variable "integrity_policy_report_only" {
  type = object({
    value = optional(string, "blocked-destinations=(script),sources=(inline)")
    report_to = optional(string, "default")
    override = optional(bool, true)
  })
  default = {}
}

variable "permissions_policy" {
  type        = object({
    value    = optional(string, "accelerometer=(),ambient-light-sensor=(),autoplay=(),battery=(),camera=(),cross-origin-isolation=(),display-capture=(),document-domain=(),encrypted-media=(),execution-while-not-rendered=(),execution-while-out-of-viewport=(),fullscreen=(),geolocation=(),gyroscope=(),hid=(),idle-detection=(),interest-cohort=(),magnetometer=(),microphone=(),midi=(),navigation-override=(),payment=(),picture-in-picture=(),publickey-credentials-get=(),screen-wake-lock=(),serial=(),sync-xhr=(),usb=(),web-share=(),xr-spatial-tracking=()")
    report_to = optional(string, "default") # Always default
    override = optional(bool, true)
  })
  default     = {}
}

variable "permissions_policy_report_only" {
  type        = object({
    value    = optional(string, "accelerometer=(),ambient-light-sensor=(),autoplay=(),battery=(),camera=(),cross-origin-isolation=(),display-capture=(),document-domain=(),encrypted-media=(),execution-while-not-rendered=(),execution-while-out-of-viewport=(),fullscreen=(),geolocation=(),gyroscope=(),hid=(),idle-detection=(),interest-cohort=(),magnetometer=(),microphone=(),midi=(),navigation-override=(),payment=(),picture-in-picture=(),publickey-credentials-get=(),screen-wake-lock=(),serial=(),sync-xhr=(),usb=(),web-share=(),xr-spatial-tracking=()")
    report_to = optional(string, "default") # Always default
    override = optional(bool, true)
  })
  default     = {}
}

variable "network_error_logging" {
  type        = object({
    max_age   = optional(number, 31536000)
    include_subdomains = optional(bool, true)
    failure_fraction = optional(string, "1")
    report_to = optional(string, "default")
    override  = optional(bool, true)
  })
  default     = {}
}

variable "referrer_policy" {
  type = object({
    value   = optional(string, "no-referrer")
    #report_to = optional(string, "default") # not supported
    override = optional(bool, true)
  })
  default = {}
}

variable "require_document_policy" {
  type = object({
    value = optional(string, "")
    report_to = optional(string, "default")
    override = optional(bool, true)
  })
  default = {}
}

variable "sec_required_document_policy" {
  type = object({
    value = optional(string, "")
    report_to = optional(string, "default")
    override = optional(bool, true)
  })
  default = {}
}

variable "server_timing" {
  description = "Adds CloudFronts Server-Timing"
  type = object({
    sampling_rate = optional(number, 0)
  })
  default = {}
}

variable "strict_transport_security" {
  type = object({
    access_control_max_age_sec = optional(number, 63072000)
    include_subdomains = optional(bool, true)
    preload = optional(bool, true)
    override = optional(bool, true)
  })
  default = {}
}

variable "x_content_type_options" {
  type = object({
    value    = optional(string, "nosniff")
    override = optional(bool, true)
  })
  default = {}
}

variable "x_frame_options" {
  type = object({
    value     = optional(string, "DENY")
    override  = optional(bool, true)
  })
  default = {}
}

variable "x_permitted_cross_domain_policies" {
  type = object({
    value     = optional(string, "none")
    override  = optional(bool, true)
  })
  default = {}
}

# variable "x_xss_protection" {
#   type = object({
#     mode_block = optional(bool, true)
#     protection = optional(bool, true)
#     override   = optional(bool, true)
#   })
#   default = {}
# }

variable "custom_headers" {
  type        = list(object({
    header = string
    value = optional(string, null)
    override = optional(bool, true)
  }))
  default     = [{
    header   = "Server"
    value    = "_"
    override = true
  }]
}

variable "remove_headers" {
  type        = list(object({
    header = string
  }))
  default     = []
}