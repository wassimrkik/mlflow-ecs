terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74"
    }
  }
}

provider "aws" {
  region = var.awsregion
  default_tags {
    tags = {
      Project = "CHC AnP"
      Owner   = "Terraform"
    }
  }
}