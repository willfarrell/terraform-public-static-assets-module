variable "name" {
  type        = string
  description = "{env}-{name}"
}

variable "min_ttl" {
  type = number
  default = 0
}

variable "default_ttl" {
  type = number
  default = 86400
}

variable "max_ttl" {
  type = number
  default = 31536000
}

variable "cookies" {
  type = list(string)
  default = []
}

variable "headers" {
  type = list(string)
  default = []
}

variable "query_string_behavior" {
  type = string
  description = "only set to all*"
  default = ""
}
variable "query_strings" {
  type = list(string) # list(string) or bool
  default = []
}

variable "compress" {
  type = bool
  default = false
}
