// example.com
variable "domain" {
  type = string
}

variable "key_management_service_arn" {
  type = string
  default = ""
}

// { "":"", www:"" }
variable "cloudfront" {
  type = map(string)
  default = {}
}

variable "https" {
  type = map(list(string))
  default = {
    "" = [
      "1 . alpn=\"h3\" no-default-alpn",
      "2 . alpn=\"h2\""
    ]
  }
}

variable "mx" {
  type = map(list(string))
  default = {
    "" = ["0 ."]
  }
}

variable "caa" {
  type = map(list(string))
  default = {
    "" = [
      "0 issue \"amazonaws.com\"",
      "128 issue \"letsencrypt.org\"",
      # "0 iodef \"mailto:caa@${var.domain}.report-to.org\""
    ]
  }
}

# https://simonandrews.ca/articles/how-to-set-up-spf-dkim-dmarc
variable "txt" {
  description = "SPF and DMARC need to be included"
  type = map(list(string))
  default = {
    "" = [
      "v=spf1 -all",
      # "v=TLSRPTv1;rua=mailto:tlsrpt@${var.domain}.report-to.org"
    ]
    "_dmarc" = ["v=DMARC1; p=reject; sp=reject"]
    "*._domainkey" = ["v=DKIM1; p="]
  }
}

variable "cname" {
  type = map(list(string))
  default = {}
}

variable "ns" {
  type = map(list(string))
  default = {}
}