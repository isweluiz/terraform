resource "aws_instance" "docker" {

  count = var.instances_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ansible_key_name
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              apt-get update -y && apt-get install git -y 
              cd /opt
              git clone https://github.com/RotherOSS/otobo-docker.git --branch rel-10_1 --single-branch
              cd /opt/otobo-docker
              cp -p .docker_compose_env_http .env
              sudo sed -i 's/OTOBO_DB_ROOT_PASSWORD\=/OTOBO_DB_ROOT_PASSWORD\=databaseadminotobo2050/g' /opt/otobo-docker/.env
              EOF
  user_data_replace_on_change = true

  root_block_device {
    delete_on_termination = true
    volume_size           = var.instance_root_disk_size
    volume_type           = var.instance_root_disk_type
  }

  tags = {
    Name        = format("%02s-%s.%s.%s.aws", count.index + 1, var.service_name, var.env, var.aws_main_region)
    team        = var.team_name
    environment = var.env
  }
}

