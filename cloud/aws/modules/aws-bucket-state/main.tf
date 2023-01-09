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
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }


}

provider "aws" {
  region = "us-east-2"
}