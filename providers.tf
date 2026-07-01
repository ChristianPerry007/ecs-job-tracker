terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.51.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Configuration options
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}