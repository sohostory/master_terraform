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

data "aws_ami" "latest_ubuntu_server" {
  owners = ["099720109477"]
  most_recent = true
  
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}
resource "aws_key_pair" "test_ssh_key" {
  key_name   = "test_ssh_key"
  public_key = file(var.test_ssh_key)
}
resource "aws_instance" "server" {
  ami                         = data.aws_ami.latest_ubuntu_server.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.webapps.id
  vpc_security_group_ids = [aws_default_security_group.default_sec_group.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.test_ssh_key.key_name
  user_data = file("./entry-script.sh")
  tags = {
    Name = "Server"
  }
}