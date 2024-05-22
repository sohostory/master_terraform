terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "production" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Production ${var.main_vpc_name}"
  }
}

resource "aws_subnet" "webapps" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = var.web_subnet
  availability_zone = var.subnet_zone
  tags = {
    Name = "Web Application Subnet"
  }
}

resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.production.id
  tags = {
    Name = "${var.main_vpc_name} Internet Gateway"
  }
}

resource "aws_default_route_table" "rt" {
  default_route_table_id = aws_vpc.production.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_web_igw.id
  }
  tags = {
    Name = "my-default-rt"
  }
}

resource "aws_default_security_group" "default_sec_group" {
  vpc_id = aws_vpc.production.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Default Security Group"
  }
}
resource "aws_instance" "server" {
  ami                         = "ami-0cbe318e714fc9a82"
  instance_type               = "t2.micro"
  count                       = 2
  subnet_id                   = aws_subnet.webapps.id
  associate_public_ip_address = true
  tags = {
    Name = "Server"
  }
}