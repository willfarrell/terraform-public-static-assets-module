
resource "aws_cloudfront_origin_request_policy" "main" {
  name        = var.name
  cookies_config {
    cookie_behavior =  var.cookies == true ? "all" : length(var.cookies) == 0 ? "none" : var.cookie_behavior
    dynamic "cookies" {
      for_each = var.cookies == true ? [] : length(var.cookies) == 0 ? [] : [1]
      content {
        items = var.cookies
      }
    }
  }
  headers_config {
    header_behavior = var.headers == true ? "allViewer" : length(var.headers) == 0 ? "none" : var.header_behavior
    dynamic "headers" {
      for_each = var.headers == true ? [] : length(var.headers) == 0 ? [] : [1]
      content {
        items = var.headers
        /*
        Included by default:
        cache-control
        host: ****.lambda-url.ca-central-1.on.aws
        origin
        pragma
        user-agent: Amazon CloudFront
        via
        x-amz-cf-id
        x-amzn-tls-cipher-suite
        x-amzn-tls-version
        x-amzn-trace-id
        x-forwarded-for
        x-forwarded-port
        x-forwarded-proto
        
        */
      }
    }
  }
  query_strings_config {
    query_string_behavior = var.query_strings == true ? "all" : length(var.query_strings) == 0 ? "none" : var.query_string_behavior
    dynamic "query_strings" {
      for_each = var.query_strings == true ? [] : length(var.query_strings) == 0 ? [] : [1]
      content {
        items = var.query_strings
      }
    }
  }
}

