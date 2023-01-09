resource "aws_route53_zone" "main" {
  name = var.main_zone

  tags = {
    Environment = var.env
    Team        = var.team_name
    Service     = var.service_name
  }
}