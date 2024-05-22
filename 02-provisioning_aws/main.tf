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

resource "aws_subnet" "webapps" {
  vpc_id = aws_vpc.production.id
  cidr_block = "192.168.0.32/27"
  availability_zone = "us-west-1a"
  tags = {
    Name = "Web Application Subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.production.id
  tags = {
    Name = "Production Internet Gateway"
  }
}

resource "aws_default_route_table" "rt" {
  default_route_table_id = aws_vpc.production.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Production Route Table"
  }
}
resource "aws_instance" "server" {
  ami = "ami-0cbe318e714fc9a82"
  instance_type = "t2.micro"
  count = 2
  subnet_id = aws_subnet.webapps.id
  associate_public_ip_address = true
  tags = {
    Name = "Server"
  }
}