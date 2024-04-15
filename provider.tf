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
      APP_GEN1          = "AnP Spend allocation"
      Project           = "AnP"
      Owner             = "CHC"
      CE_Application_ID = "APM0069253"
      createdBy         = "Terraform"
    }
  }
}