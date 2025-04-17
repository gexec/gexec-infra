terraform {
  backend "s3" {
    bucket = "gexec-terraform"
    key    = "infra"
    region = "eu-central-1"
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "cloudflare_zone" "gexec" {
  name = "gexec.eu"

  account = {
    id = var.cloudflare_account
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
