provider "helm" {
  kubernetes {
    config_path = var.main_kube_config
  }
}
