
resource "aws_security_group" "aws_security_eip" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-014eac810307cc61c"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.lb.public_ip}/32"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}