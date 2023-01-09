resource "github_repository_file" "github_repository_file_gitignore" {
  repository          = github_repository.github_repo_ansible.name
  branch              = "main"
  file                = ".gitignore"
  content             = "**/*.tfstate"
  commit_message      = "Managed by Terraform"
  commit_author       = "luiz"
  commit_email        = "luiz.terraform@xpto.com"
  overwrite_on_create = true
}

resource "github_repository_file" "github_repository_file_readme" {
  repository          = github_repository.github_repo_ansible.name
  branch              = "main"
  file                = "README.md"
  content             = "# Ansible Repository - Managed By Terraform\n Here we can manage our repository files\n ```bash\n $terraform --help\n ```\n![repo-image](https://i.imgur.com/XTcaAY6.png)\n If we want to delete the Development Branch\n```bash\n $terraform destroy --target github_branch.github_branch_development\n```\nIf we want to apply the change in one resource\n```bash\n $terraform apply --target github_repository_file.github_repository_file_readme\n```"
  commit_message      = "NEW README FILE"
  commit_author       = "luiz"
  commit_email        = "luiz.terraform@xpto.com"
  overwrite_on_create = true
}