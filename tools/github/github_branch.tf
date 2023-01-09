resource "github_branch" "github_branch_development" {
  repository = github_repository.github_repo_ansible.name
  branch     = "development"
}