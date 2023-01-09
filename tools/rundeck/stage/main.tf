terraform {
  required_providers {
    rundeck = {
      source  = "rundeck/rundeck"
      version = "0.4.2"
    }
  }
}

provider "rundeck" {
  url         = "http://rundeck.example.com:4440/"
  api_version = "38"
  auth_token  = "abcd1234"
}

resource "rundeck_project" "terraform" {
  name                 = "terraform"
  description          = "Sample Application Created by Terraform Plan"
  ssh_key_storage_path = rundeck_private_key.terraform.path
  resource_model_source {
    type = "file"
    config = {
      format = "resourcexml"
      # This path is interpreted on the Rundeck server.
      file                      = "/home/rundeck/resources.xml"
      writable                  = "true"
      generateFileAutomatically = "true"
    }
  }
  extra_config = {
    "project.label" = "Terraform Example"
  }
}

resource "rundeck_job" "bounceweb" {
  name              = "Bounce All Web Servers"
  project_name      = rundeck_project.terraform.name
  node_filter_query = "tags: web"
  description       = "Restart the service daemons on all the web servers"

  command {
    shell_command = "sudo service anvils restart"
  }
}

resource "rundeck_public_key" "terraform" {
  path         = "terraform/id_rsa.pub"
  key_material = "ssh-rsa yada-yada-yada"
}

resource "rundeck_private_key" "terraform" {
  path         = "terraform/id_rsa"
  key_material = "$${file(\"id_rsa.pub\")}"
}

data "local_file" "acl" {
  filename = "${path.cwd}/acl.yaml"
}

resource "rundeck_acl_policy" "example" {
  name = "ExampleAcl.aclpolicy"

  policy = data.local_file.acl.content
}