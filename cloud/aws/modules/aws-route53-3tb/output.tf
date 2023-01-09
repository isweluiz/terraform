output "aws_route_zone" {
  value = aws_route53_zone.main.name_servers
}