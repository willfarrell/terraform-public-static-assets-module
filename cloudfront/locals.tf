data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region     = data.aws_region.current.region
  tags       = {}
  name       = var.name
  account_id  = data.aws_caller_identity.current.account_id
  
  origins = concat(var.origins, var.origin_groups)

  #sse_algorithm = "AES256"

  logging_bucket = var.logging_bucket != "" ? var.logging_bucket : "${var.name}-${terraform.workspace}-edge-logs"
}

