terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }

}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "aws_instance_01_ubuntu" {
  ami                         = "ami-097a2df4ac947655f"
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 10
    volume_type           = "gp2"
    encrypted             = true
  }
  tags = local.common_tags
}

locals {
  Name         = "instance"
  service_name = "forum"
  owner        = "Community Team"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}