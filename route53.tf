resource "aws_route53_record" "ANP-ML-API" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dns_name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.ANP-ML-API.dns_name]
  depends_on = [
    aws_lb.ANP-ML-API
  ]
}