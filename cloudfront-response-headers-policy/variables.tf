variable "name" {
  type        = string
  description = "{env}-{name}"
}

variable "mimes" {
  description = "apply default for common types: html, js"
  type = list(string)
  default = []
}

# All
variable "strict_transport_security" {
  type = object({
    access_control_max_age_sec = optional(number, 63072000)
    include_subdomains = optional(bool, true)
    preload = optional(bool, true)
    override = optional(bool, true)
  })
  default = {}
}

## OPTIONS
variable "cors" {
  type = object({
    access_control_allow_credentials = optional(bool, false)
    access_control_allow_headers =  optional(list(string), ["*"])
    access_control_allow_methods = optional(list(string), ["HEAD"])
    access_control_allow_origins = optional(list(string), [""])
    override = optional(bool, true)
  })
  default = {}
}

# HTML, JS
variable "coep" {
  type = object({
    policy = optional(string, "require-corp")
    override = optional(bool, true)
  })
  default = {}
}

variable "coop" {
  type = object({
    policy = optional(string, "same-origin")
    override = optional(bool, true)
  })
  default = {}
}

variable "corp" {
  type = object({
    policy = optional(string, "same-origin")
    override = optional(bool, true)
  })
  default = {}
}

variable "content_security" {
  type        = object({
    policy    = optional(string, "default-src 'none';base-uri 'none';connect-src 'none';form-action 'none';frame-ancestors 'none';sandbox allow-same-origin;upgrade-insecure-requests;report-to csp;require-trusted-types-for 'script'")
    override  = optional(bool, true)
  })
  default     = null
}

variable "permissions" {
  type        = object({
    policy    = optional(string, "accelerometer=(),ambient-light-sensor=(),autoplay=(),battery=(),camera=(),cross-origin-isolation=(),display-capture=(),document-domain=(),encrypted-media=(),execution-while-not-rendered=(),execution-while-out-of-viewport=(),fullscreen=(),geolocation=(),gyroscope=(),hid=(),idle-detection=(),interest-cohort=(),magnetometer=(),microphone=(),midi=(),navigation-override=(),payment=(),picture-in-picture=(),publickey-credentials-get=(),screen-wake-lock=(),serial=(),sync-xhr=(),usb=(),web-share=(),xr-spatial-tracking=()")
    override = optional(bool, true)
  })
  default     = null
}

variable "content_type_options" {
  type = object({
    override = optional(bool, true)
  })
  default = {}
}

variable "frame_options" {
  type = object({
    frame_option = optional(string, "DENY")
    override     = optional(bool, true)
  })
  default = {}
}

variable "referrer" {
  type = object({
    policy   = optional(string, "no-referrer")
    override = optional(bool, true)
  })
  default = {}
}

variable "xss_protection" {
  type = object({
    mode_block = optional(bool, true)
    protection = optional(bool, true)
    override   = optional(bool, true)
  })
  default = {}
}

variable "nel" {
  type        = object({
    report_to = optional(string, "default")
    max_age   = optional(number, 31536000)
    include_subdomains = optional(bool, true)
    override  = optional(bool, true)
  })
  default     = {}
}

variable "report_to" {
  type        = object({
    id        = optional(string, "example")
    override  = optional(bool, true)
  })
  default     = {}
}

variable "custom_headers" {
  type        = list(object({
    header = string
    value = optional(string, null)
    override = optional(bool, true)
  }))
  default     = []
}