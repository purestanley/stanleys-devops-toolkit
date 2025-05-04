variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "stanley-chidi-vpc"
}

variable "instance_tenancy" {
  description = "The instance tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "subnet_cidr_blocks" {
  description = "List of CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "subnet_names" {
  description = "Names for each subnet"
  type        = list(string)
  default     = ["subnet-az1", "subnet-az2"]
}

variable "vpc_id" {
  description = "VPC ID where the internet gateway and other resources will be created"
  type        = string
}

variable "internet_gateway_name" {
  description = "Name of the Internet Gateway"
  type        = string
  default     = "stanley-gateway"  # Use "stanley-gateway" as the default name
}

# Define the AMI ID variable for the EC2 instances
variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-084568db4383264d4"  # Replace with your AMI ID
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where instances will be launched"
  type        = string
}


variable "frontend_sg_name" {
  description = "Security group name for frontend servers"
  type        = string
  default     = "frontend_sg"
}

variable "backend_sg_name" {
  description = "Security group name for backend servers"
  type        = string
  default     = "backend_sg"
}


variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "stanleys-new-terraform-bucket"  # This should be a globally unique name
}

variable "bucket_tags" {
  description = "Tags for the S3 bucket"
  type = map(string)
  default = {
    Name        = "My Terraform Bucket"
    Environment = "Dev"
  }
}

variable "bucket_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "public_object_key" {
  description = "Key for the public read example object"
  type        = string
  default     = "public-read-example.txt"
}

variable "public_object_content" {
  description = "Content for the public read example object"
  type        = string
  default     = "This file is publicly readable."
}

variable "object_acl" {
  description = "ACL for the public read example object"
  type        = string
  default     = "public-read"
}

variable "iam_user_name" {
  description = "The IAM user's name"
  type        = string
  default     = "BOB"
}

variable "iam_user_owner" {
  description = "Name of the person managing the IAM user"
  type        = string
  default     = "Stanley"
}

variable "iam_user_description" {
  description = "The IAM user's role or purpose"
  type        = string
  default     = "CTO"
}

variable "attach_admin_policy" {
  description = "Set to true to give the IAM user administrator access"
  type        = bool
  default     = true
}
