
// ["www.example.com,example.com","api.example.com"]
variable "domains" {
  type = list(string)
}

variable "email" {
  type = string
}

variable "key-type" {
  type = string
  default = "ecdsa"
}

variable "dead_letter_arn" {
  type = string
}

variable "dead_letter_policy_arn" {
  type = string
}

// TODO
variable "hostedzone_arns" {
  type = list(string)
}