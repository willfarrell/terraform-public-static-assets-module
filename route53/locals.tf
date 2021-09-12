locals {
  is_root = length(split(".", var.domain)) == 2
}