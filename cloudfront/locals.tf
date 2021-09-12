module "defaults" {
  source = "git@github.com:willfarrell/terraform-defaults?ref=v0.1.0"
  name   = var.name
  tags   = var.default_tags
}

locals {
  region     = module.defaults.region
  tags       = module.defaults.tags
  name       = module.defaults.name
  account_id = module.defaults.account_id

  bucket_domain_name = var.bucket_domain_name != "" ? var.bucket_domain_name : aws_s3_bucket.main[0].bucket_domain_name

  //sse_algorithm = "AES256"

  logging_bucket = var.logging_bucket != "" ? var.logging_bucket : "${module.defaults.name}-${terraform.workspace}-edge-logs"
}

