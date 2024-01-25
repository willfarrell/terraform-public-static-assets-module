
resource "aws_cloudfront_cache_policy" "main" {
  name        = var.name
  min_ttl     = var.min_ttl
  default_ttl = min(max(var.min_ttl, var.default_ttl),var.max_ttl)
  max_ttl     = var.max_ttl
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = length(var.cookies) == 0 ? "none" : "whitelist"
      dynamic "cookies" {
        for_each = length(var.cookies) == 0 ? [] : [1]
        content {
          items = var.cookies
        }
      }
    }
    headers_config {
      header_behavior = length(var.headers) == 0 ? "none" : "whitelist"
      dynamic "headers" {
        for_each = length(var.headers) == 0 ? [] : [1]
        content {
          items = var.headers
        }
      }
    }
    query_strings_config {
      query_string_behavior = var.query_string_behavior != "" ? var.query_string_behavior : length(var.query_strings) == 0 ? "none" : "whitelist"
      dynamic "query_strings" {
        for_each = length(var.query_strings) == 0 ? [] : [1]
        content {
          items = var.query_strings
        }
      }
    }
    enable_accept_encoding_brotli = var.compress
    enable_accept_encoding_gzip = var.compress
  }
}

