resource "aws_ecr_repository" "Anp-API" {
  name                 = "anp/mldev-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "Anp-API-MLFLOW" {
  name                 = "anp/mlfow"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}