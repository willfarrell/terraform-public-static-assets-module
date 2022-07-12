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

variable "cors_origins" {
  type    = list(string)
  default = [
    "*"]
  description = "S3 CORS"
}

variable "response_headers_policy_id" {
  type  = string
  default = ""
}

variable "origin_path" {
  type = string
  default = "/"
}

variable "origins" {
  type = list(any)
  default = []
}

// brotoli is not supported, set to false if doing self compression
variable "compress" {
  type = bool
  default = true
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

# lambda@edge
variable "lambda" {
  type    = map(string)
  default = {}
}

// Allowed: 400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504
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

// Override S3 bucket used
variable "bucket_domain_name" {
  default = ""
}
