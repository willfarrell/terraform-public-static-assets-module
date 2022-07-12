resource "aws_s3_bucket" "main" {
  count = var.bucket_domain_name == "" ? 1 : 0
  bucket              = "${local.name}-${terraform.workspace}-static-assets"
  acl                 = "private"
  acceleration_status = "Enabled"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = var.cors_origins
    expose_headers  = [
      "ETag",
      "Cache-Control",
      "Content-Type"
    ]
    max_age_seconds = 3000
  }

  #versioning {
  #  enabled = false
  #}

  logging {
    target_bucket = local.logging_bucket
    target_prefix = "AWSLogs/${local.account_id}/S3/${local.name}-${terraform.workspace}-static-assets/"
  }

  // Requires origin-request (https://aws.amazon.com/blogs/networking-and-content-delivery/serving-sse-kms-encrypted-content-from-s3-using-cloudfront/)
  //  server_side_encryption_configuration {
  //    rule {
  //      apply_server_side_encryption_by_default {
  //        sse_algorithm = "aws:kms"
  //      }
  //    }
  //  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = merge(
    local.tags,
    {
      Name     = "${local.name} Static Assets"
      Security = "SSE:AWS"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "main" {
  count = var.bucket_domain_name == "" ? 1 : 0
  bucket = aws_s3_bucket.main[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3" {
  count = var.bucket_domain_name == "" ? 1 : 0
  statement {
    sid = "FindBucket"
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.main[0].arn,
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.main.iam_arn,
      ]
    }
  }

  statement {
    sid = "GetAssets"
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.main[0].arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.main.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  count = var.bucket_domain_name == "" ? 1 : 0
  bucket = aws_s3_bucket.main[0].id
  policy = data.aws_iam_policy_document.s3[0].json
}

