terraform {
  backend "s3" {
    bucket = "gexec-terraform"
    key    = "infra"
    region = "eu-central-1"
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.23.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.58.0"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}
