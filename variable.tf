variable "vpc_cidr_block" {}
variable "instance_tenancy" {}
variable "vpc_name" {}

variable "subnet_cidr_blocks" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "subnet_names" {
  type = list(string)
}

variable "internet_gateway_name" {}

variable "frontend_sg_name" {}
variable "backend_sg_name" {}

variable "ami" {}
variable "instance_type" {}

variable "bucket_name" {}

variable "iam_user_name" {}
variable "iam_user_owner" {}
variable "attach_admin_policy" {
  type    = bool
  default = false
}

