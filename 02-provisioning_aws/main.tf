terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "production" {
  cidr_block = "192.168.0.0/24"
  tags = {
    Name = "Production VPC"
  }
}