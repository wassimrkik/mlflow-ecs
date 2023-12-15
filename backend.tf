terraform {
  backend "s3" {
    key = "api/api.tfstate"
  }
}