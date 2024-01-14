resource "aws_ecr_repository" "Anp-UI-FE" {
  name                 = "anp/mldev-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}