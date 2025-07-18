
output "id" {
  value = aws_cloudfront_distribution.main.id
}

output "arn" {
  value = aws_cloudfront_distribution.main.arn
}

output "domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.main.hosted_zone_id
}

output "origin_access_identity_arn" {
  value = aws_cloudfront_origin_access_identity.main.iam_arn
}

