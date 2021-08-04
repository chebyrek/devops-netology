terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "testnetologytfbackend"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}