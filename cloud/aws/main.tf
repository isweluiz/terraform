terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }

}

provider "aws" {
  region = var.aws_main_region
}

################ Ansible Keys 

resource "aws_key_pair" "ansible" {
  key_name   = var.ansible_key_name
  public_key = var.ansible_public_key
}

################ DNS 

module "aws-route53-3tb" {
  source = "./modules/aws-route53-3tb/"

  team_name    = "infra"
  service_name = "dns"
  env          = var.env
  main_zone    = "3tb.com.br"
}


# Instances
# Docker and Github Runner + Ansible Machine
# terraform plan -target=module.aws-docker -target=aws_key_pair.ansible
# terraform apply -target=module.aws-docker -target=aws_key_pair.ansible
# terraform destroy -target=module.aws-docker -target=aws_key_pair.ansible --auto-approve

module "aws-docker" {
  source = "./modules/aws-docker/"

  team_name               = "infra"
  service_name            = "docker"
  env                     = var.env
  ansible_key_name        = var.ansible_key_name
  aws_main_region         = var.aws_main_region
  ami_id                  = var.ami_id
  instance_type           = "t2.medium"
  instances_count_docker  = 2
  instance_root_disk_size = 10
  #Runner
  instances_count_gh_runner = 1
  service_name_gh           = "ghrunner"
}

/*
module "aws-instance-template" {
  source = "./modules/aws-instance-template/"

  service_name            = "instance"
  ansible_key_name        = var.ansible_key_name
  aws_main_region         = var.aws_main_region
  env                     = var.env
  ami_id                  = var.ami_id
  instance_type           = "t2.micro"
  instances_count         = 2
  instance_root_disk_size = 10
  team_name               = "infra"
}
*/


#format("%s-%02s.%s.%s.aws", "devops-tools", "1", "dev", "us-east-02")
# terraform apply -target=module.aws-docker -target=aws_key_pair.ansible
# terraform plan -target=module.aws-docker -target=aws_key_pair.ansible
# terraform apply -replace="module.aws-docker.aws_instance.docker"
# terraform taint module.aws-docker.aws_instance.docker
# terraform taint module.aws-docker.aws_instance.docker[0]
# terraform plan -target=module.aws-route53-3tb
#terraform plan module.aws-docker.aws_instance.docker