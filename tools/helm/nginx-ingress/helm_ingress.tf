resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx-controller"

  repository       = var.ingress_repository
  chart            = var.ingress_chart
  version          = var.ingress_version
  namespace        = var.ingress_namespace
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "cluster.enabled"
    value = "true"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

}