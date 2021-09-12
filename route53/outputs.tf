output "NS" {
  value = aws_route53_zone.main
}

//output "DNSKEY" {
//  value = aws_route53_key_signing_key.main[0].dnskey_record
//}
//
//output "DS" {
//  value = aws_route53_key_signing_key.main[0].ds_record
//}