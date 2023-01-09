variable "main_zone" {
    type = string
}

variable "aws_main_region" {
  type    = string
  default = "us-east-2"
}

variable "env" {
  type = string
  default = "stage"
}

variable "team_name" {
  type = string
}

variable "service_name" {
  type = string
}