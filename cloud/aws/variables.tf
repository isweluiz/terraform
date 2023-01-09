variable "aws_main_region" {
  type    = string
  default = "us-east-2"
}

variable "ami_id" {
  type    = string
  default = "ami-0fb653ca2d3203ac1"

  validation {
    condition     = length(var.ami_id) > 4 && substr(var.ami_id, 0, 4) == "ami-"
    error_message = "The ami_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "env" {
  type    = string
  default = "dev"

}

variable "ansible_key_name" {
  type      = string
  sensitive = true
}

variable "ansible_public_key" {
  type      = string
  sensitive = true
}
