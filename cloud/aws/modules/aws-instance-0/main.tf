terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }

  backend "s3" {
    # Replace this with your bucket name!
    bucket = "state-terraform-s3-resource"
    key    = "global/s3/web/terraform.tfstate"
    region = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
  #access_key = ""
  #secret_key = "" 
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
  tags = {
    Name = "web-00"
  }
}

output "aws_intance_associate_public_ip_address" {
  value = [aws_instance.aws_instance_01_ubuntu.associate_public_ip_address, aws_instance.aws_instance_01_ubuntu.public_dns]
}

output "aws_intance_private_ip" {
  value = aws_instance.aws_instance_01_ubuntu.private_ip
}

output "aws_intance_public_arn" {
  value = aws_instance.aws_instance_01_ubuntu.arn
}

output "aws_intance_public_public_ip" {
  value = aws_instance.aws_instance_01_ubuntu.public_ip
}