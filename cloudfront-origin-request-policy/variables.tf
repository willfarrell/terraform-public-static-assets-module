variable "name" {
  type        = string
  description = "{env}-{name}"
}

variable "cookie_behavior" {
  type = string
  default = "whitelist"
}

variable "cookies" {
  type = any # list(string)
  default = []
}

variable "header_behavior" {
  type = string
  default = "whitelist"
}

variable "headers" {
  type = any # list(string)
  default = []
}

variable "query_string_behavior" {
  type = string
  default = "whitelist"
}

variable "query_strings" {
  type = any # list(string) or bool
  default = []
}