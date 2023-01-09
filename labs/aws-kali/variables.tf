variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "ami" {
  type    = string
  default = "ami-09a328f2169477785"
}

variable "env" {
  type    = string
  default = "stage"

}

variable "service" {
  type    = string
  default = "security"

}

variable "ansible_key_name" {
  type = string
}

variable "ansible_public_key" {
  type      = string
  sensitive = true
}

variable "vpc_id_main" {
  type    = string
  default = "vpc-014eac810307cc61c"

  validation {
    condition     = length(var.vpc_id_main) > 3 && substr(var.vpc_id_main, 0, 4) == "vpc-"
    error_message = "The vpc_id_main value must be a valid vpc id, starting with \"vpc-\"."
  }
}

variable "instance_root_disk_size" {
  type    = number
  default = 15
}

variable "instance_root_disk_type" {
  type    = string
  default = "standard"
}

variable "ingress_sg" {
  description = "Security Group Ports"
  type        = list(number)
  default     = [22, 80, 8080, 443, 3306, 4444, 444, 5666]
}
