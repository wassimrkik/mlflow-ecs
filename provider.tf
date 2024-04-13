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
      Project           = "AnP"
      Owner             = "CHC"
      modifiedOn        = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
      CE_Application_ID = "APM0069253"
      createdBy         = "Terraform"
    }
  }
}