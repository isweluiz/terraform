variable "region" {
  default = "us-west-2"
}

variable "main_kube_config" {
  type    = string
  default = "~/.kube/config"

}

variable "ingress_repository" {
  type    = string
  default = "https://kubernetes.github.io/ingress-nginx"
}

variable "ingress_chart" {
  type    = string
  default = "ingress-nginx"
}

variable "ingress_namespace" {
  type    = string
  default = "nginx-ingress"
}

variable "ingress_version" {
  type    = string
  default = "4.0.18"

}