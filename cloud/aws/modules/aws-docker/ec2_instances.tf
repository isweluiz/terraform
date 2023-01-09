resource "aws_instance" "docker" {

  count = var.instances_count_docker

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ansible_key_name
  associate_public_ip_address = true
  user_data                   = <<-EOF
            #!/bin/bash
            apt-get update -y && apt-get install git -y && apt-get install docker && apt-get install docker-compose
            EOF

  root_block_device {
    delete_on_termination = true
    volume_size           = var.instance_root_disk_size
    volume_type           = var.instance_root_disk_type
  }

  tags = {
    Name = format("%02s-%s.%s.%s.aws",count.index + 1, var.service_name,var.env, var.aws_main_region)
    team = var.team_name
    environment  = var.env
  }
}

resource "aws_instance" "gh_runner_deploy" {

  count = var.instances_count_gh_runner

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ansible_key_name
  associate_public_ip_address = true
  user_data                   = <<-EOF
            #!/bin/bash
            apt-get update -y && apt-get install git -y 
            sudo apt-add-repository ppa:ansible/ansible
            sudo apt update -y && sudo apt-get install ansible
            EOF

  root_block_device {
    delete_on_termination = true
    volume_size           = var.instance_root_disk_size
    volume_type           = var.instance_root_disk_type
  }

  tags = {
    Name = format("%02s-%s.%s.%s.aws",count.index + 1, var.service_name_gh,var.env, var.aws_main_region)
    team = var.team_name
    environment  = var.env
  }
}
