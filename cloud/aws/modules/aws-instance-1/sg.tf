resource "aws_security_group" "instance" {
  name = "terraform-web-server-instance"

  ingress {
    description = "WEB APP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

variable "common_ingress_allowed_ports" {
  type = list(string)
  default = [
    "22",
    "8080"
  ]
}