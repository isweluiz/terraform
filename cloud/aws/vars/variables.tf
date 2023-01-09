variable "aws_main_region" {
  type    = string
  default = "us-west-1"
}

variable "ami_id" {
  type    = string
  default = "ami-0f4feb99425e13b50"

  validation {
    condition     = length(var.ami_id) > 4 && substr(var.ami_id, 0, 4) == "ami-"
    error_message = "The ami_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "env" {
  type    = string
  default = "dev"
}

variable "instance_root_disk_size" {
  type    = number
  default = 10
}

variable "instances_count_docker" {
  type    = number
  default = 1

  validation {
    condition     = var.instances_count_docker > 0 && var.instances_count_docker <= 10
    error_message = "The instances_count value must be > 0 and < 10"
  }

}

variable "instance_type" {
  type    = string
  default = "t3a.large"
}

variable "instance_root_disk_type" {
  type    = string
  default = "gp2"
}

variable "vpc_id_main" {
  type    = string
  default = "vpc-014eac810307cc61c"

  validation {
    condition     = length(var.vpc_id_main) > 3 && substr(var.vpc_id_main, 0, 4) == "vpc-"
    error_message = "The vpc_id_main value must be a valid vpc id, starting with \"vpc-\"."
  }
}

variable "ansible_key_name" {
  type      = string
  sensitive = true

}

variable "service_name" {
  type    = string
  default = "infra"

}

variable "team_name" {
  type    = string
  default = "infra"

}

## GH RUNNER 

variable "service_name_gh" {
  type    = string
  default = "infra"

}

variable "instances_count_gh_runner" {
  type    = number
  default = 1

  validation {
    condition     = var.instances_count_gh_runner > 0 && var.instances_count_gh_runner <= 10
    error_message = "The instances_count value must be > 0 and < 10"
  }

}