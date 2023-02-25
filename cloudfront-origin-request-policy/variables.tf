variable "name" {
  type        = string
  description = "{env}-{name}"
}

variable "cookies" {
  type = list(string)
  default = []
}

variable "headers" {
  type = list(string)
  default = []
}

variable "query_strings" {
  type = any # list(string) or bool
  default = []
}