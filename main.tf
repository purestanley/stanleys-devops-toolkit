terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_names[count.index]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_security_group" "frontend_sg" {
  name        = var.frontend_sg_name
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = var.frontend_sg_name
  }
}

resource "aws_security_group" "backend_sg" {
  name        = var.backend_sg_name
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = var.backend_sg_name
  }
}

resource "aws_instance" "backend" {
  count         = 4
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnets[0].id
  security_groups = [aws_security_group.backend_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "backend-server-${count.index + 1}"
  }
}

resource "aws_instance" "frontend" {
  count         = 2
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnets[0].id
  security_groups = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "frontend-server-${count.index + 1}"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_block_public_access" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "stanley" {
  name = var.iam_user_name
  path = "/"

  tags = {
    Owner       = var.iam_user_owner
    Description = "IAM user created via Terraform"
  }
}

resource "aws_iam_access_key" "stanley" {
  user = aws_iam_user.stanley.name
}

resource "aws_iam_user_policy_attachment" "stanley_admin" {
  count      = var.attach_admin_policy ? 1 : 0
  user       = aws_iam_user.stanley.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
