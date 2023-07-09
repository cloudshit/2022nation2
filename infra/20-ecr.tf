resource "aws_ecr_repository" "skills_ecr" {
  name = "skills-ecr"
  force_delete = true
}
