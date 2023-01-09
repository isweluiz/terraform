terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }

}

# $ export AWS_ACCESS_KEY_ID=<id>
# $ export AWS_SECRET_ACCESS_KEY=<key>

provider "aws" {
  region = var.aws_main_region
}

##################  SSH KEY ##################
resource "aws_key_pair" "ansible" {
  key_name   = var.ansible_key_name
  public_key = var.ansible_public_key
}