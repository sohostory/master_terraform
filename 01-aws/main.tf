terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.my_vpc_name} VPC"
  }
}

# Create a subnet
resource "aws_subnet" "web" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.web_subnet
  availability_zone = "us-east-2a"
  tags = {
    Name = "Web Subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.my_vpc_name} IGW"
  }
}

# Create a default route table
resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_web_igw.id
  }
  tags = {
    Name = "my-default-rt"
  }
}

# Create a default security group
resource "aws_default_security_group" "default_sec_group" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80 
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Default Security Group"
  }
}

# Create a key pair
resource "aws_key_pair" "test_ssh_key" {
  key_name = "testing_ssh_key"
  public_key = file(var.ssh_public_key)
}

# Get latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["al2023-ami-2023.4.2024*"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

# Create a ec2 instance
resource "aws_instance" "my_vm" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.web.id
  vpc_security_group_ids = [aws_default_security_group.default_sec_group.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.test_ssh_key.key_name
  user_data = file("entry-script.sh")
  tags = {
    Name = "My EC2 Instance - Amazon Linux"
  }
}