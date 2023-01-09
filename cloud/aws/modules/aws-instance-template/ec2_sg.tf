resource "aws_security_group" "ssh_security" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id_main

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  count                = length(aws_instance.instance_web_template)
  security_group_id    = aws_security_group.ssh_security.id
  network_interface_id = aws_instance.instance_web_template[count.index].primary_network_interface_id
}
