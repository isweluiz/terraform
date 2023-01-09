# resource "aws_route53_record" "dev-ns" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "dev.example.com"
#   type    = "NS"
#   ttl     = "30"
#   records = aws_route53_zone.dev.name_servers
# }