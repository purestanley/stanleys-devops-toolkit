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

resource "aws_vpc" "stanley_chidi_vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "multi_az_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.stanley_chidi_vpc.id
  cidr_block              = var.subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_names[count.index]
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id  
  tags = {
    Name = var.internet_gateway_name  
  }
}


resource "aws_security_group" "frontend_sg" {
  name        = var.frontend_sg_name
  description = "Allow HTTP and HTTPS traffic for frontend servers"
  vpc_id      = var.vpc_id

  # Inbound Rules
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
  description = "Allow SSH traffic for backend servers"
  vpc_id      = var.vpc_id

  
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
  ami           = var.ami
  instance_type = var.instance_type
  count         = 4  
  subnet_id     = var.subnet_id  
  security_groups = [aws_security_group.backend_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "backend-server-${count.index + 1}"
  }
}


resource "aws_instance" "frontend" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = 2  
  subnet_id     = var.subnet_id  
  security_groups =[aws_security_group.frontend_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "frontend-server-${count.index + 1}"
  }
}

resource "aws_s3_bucket_versioning" "stanleys_bucket_versioning" {
  bucket = aws_s3_bucket.stanleys_bucket_123.id

  versioning_configuration {
    status = var.bucket_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket" "stanleys_bucket_123" {
  bucket = var.bucket_name
  tags   = var.bucket_tags

  lifecycle {
    prevent_destroy = true  # This MUST be a hardcoded value (true or false)
  }
}



resource "aws_s3_object" "public_object" {
  bucket  = aws_s3_bucket.stanleys_bucket_123.bucket
  key     = var.public_object_key
  content = var.public_object_content
  acl     = var.object_acl
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.stanleys_bucket_123.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.stanleys_bucket_123.arn}/*"
        Principal = "*"
      }
    ]
  })
}

resource "aws_iam_user" "bob" {
  name = var.iam_user_name
  path = "/"
  tags = {
    Owner       = "var.iam_user_owner"
    Description = "var.iam_user_description"  
  }
}

resource "aws_iam_access_key" "bob" {
  user = aws_iam_user.bob.name
}


resource "aws_iam_user_policy_attachment" "bob_admin_attach" {
  count      = var.attach_admin_policy ? 1 : 0
  user       = aws_iam_user.bob.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
