resource "aws_ecr_repository" "Anp-API-MLFLOW" {
  name                 = "anp/mlflow"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}