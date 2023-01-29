// Suggested:
// ${env}-${subdomain}-${domain}-${tld}
variable "name" {
  type        = string
  description = "AWS S3 Bucket. {env}-{name}"
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "price_class" {
  type = string
  default = "PriceClass_All" # PriceClass_All, PriceClass_200, PriceClass_100
}

variable "aliases" {
  type        = list(string)
  description = "Cloudfront Aliases"
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "web_acl_id" {
  type        = string
  default     = ""
  description = "WAF ACL ID"
}

variable "geo_restriction" {
  type = string
  default = "none"
}

variable "origins" {
  type = list(object({
    origin_id = string
    type = optional(string, "custom")
    domain_name = string
    origin_path = optional(string)
    origin_shield = optional(string, "disabled") # aws region
  }))
  default = []
}

variable "origin_groups" {
  type = list(object({
    origin_id = string
    status_codes = list(number)
    origin_ids = list(string)
  }))
  default = []
}

variable "behaviors" {
  type = list(object({
      path_pattern = optional(string, "/*")
      origin_id = string
      allowed_methods = optional(list(string), [])
      lambda = object({
        viewer-request = optional(string)
        origin-request = optional(string)
        origin-response = optional(string)
        viewer-response = optional(string)
      })
      response_headers_policy_id = optional(string)
      cache = object({
        min_ttl = optional(number, 0)
        default_ttl = optional(number, 86400)
        max_ttl = optional(number, 31536000)
        methods = optional(list(string), [])
        cookies = optional(list(string), [])
        headers = optional(list(string), []) # never forward Host
        query_strings = optional(list(string), [])
        compress = optional(bool, false)
      })
  }))
  default = []
}

variable "compress" {
  type = bool
  default = true
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

# Allowed: 400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504
variable "error_codes" {
  type    = map(string)
  default = {}
}

variable "forward_headers" {
  type = list(string)
  default = [
    "Accept",
    "Accept-Charset",
    "Accept-Encoding",
    "Accept-Language",
    "Authorization",
    "Cache-Control",
    "Content-Encoding",
    "Content-Language",
    "Content-Length",
    "Content-Type",
  ]
}

variable "logging_bucket" {
  type    = string
  default = ""
}

# Override S3 bucket used
variable "bucket_domain_name" {
  default = ""
}

variable "cors_origins" {
  type    = list(string)
  default = [
    "*"]
  description = "S3 CORS"
}
