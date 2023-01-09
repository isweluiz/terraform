resource "aws_security_group" "sg_lab" {
  name        = "sg_allowed_ports"
  description = "Docker environment - Security Groups"
  vpc_id      = var.vpc_id_main

  dynamic "ingress" {
    for_each = var.ingress_docker_sg
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  count                = length(aws_instance.docker)
  security_group_id    = aws_security_group.sg_lab.id
  network_interface_id = aws_instance.docker[count.index].primary_network_interface_id
}

