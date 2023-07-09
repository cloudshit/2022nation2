resource "aws_codecommit_repository" "code" {
  repository_name = "skills-commit"
  default_branch = "upstream"
}
