resource "aws_instance" "instance" {
  count = 1

  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.ansible_key_name
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              apt-get update -y && sudo apt install python3-pip
              cd /opt
              git clone https://github.com/joaomatosf/jexboss.git 
              git clone https://github.com/SusmithKrishnan/torghost.git #Route all your traffics through TOR
              EOF
  user_data_replace_on_change = true

  root_block_device {
    delete_on_termination = true
    volume_size           = var.instance_root_disk_size
    volume_type           = var.instance_root_disk_type
  }

  tags = {
    Name = format("%s.%s-%02s.aws", var.service, var.env, count.index + 1)
  }
}