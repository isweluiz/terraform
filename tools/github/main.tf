terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.5.0"
    }
  }
}

provider "github" {
  # Configuration options
  #token = var.token # or `GITHUB_TOKEN`
  token = "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"

}