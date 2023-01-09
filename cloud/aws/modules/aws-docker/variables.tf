variable "ingress_docker_sg" {
  description = "Docker ingress Security Group Ports"
  type = list(number)
  default = [22,80,8080,443]
}

variable "ingress_runner_sg" {
  description = "Docker ingress Security Group Ports"
  type = list(number)
  default = [22,443]
}