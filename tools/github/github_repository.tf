resource "github_repository" "github_repo_ansible" {
  name                   = "ansible-roles"
  description            = "Private repo used to share ansible roles"
  visibility             = "private"
  delete_branch_on_merge = true

  auto_init = true
}