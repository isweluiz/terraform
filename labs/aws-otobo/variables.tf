variable "ingress_docker_sg" {
  description = "Docker ingress Security Group Ports"
  type        = list(number)
  default     = [22, 80, 8080, 443]
}

variable "team_name" {
  type    = string
  default = "infra"

}

variable "service_name" {
  type    = string
  default = "docker"

}

variable "ansible_public_key" {
  type      = string
  sensitive = false
}