vpc_cidr_block     = "10.0.0.0/16"
instance_tenancy   = "default"
vpc_name           = "stanley-vpc"

subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
subnet_names       = ["stanley-subnet-1", "stanley-subnet-2"]

internet_gateway_name = "stanley-igw"

frontend_sg_name = "frontend-sg"
backend_sg_name  = "backend-sg"

ami             = "ami-084568db4383264d4" # Replace with valid AMI
instance_type   = "t2.micro"

bucket_name     = "stanleys-unique-terraform-bucket"

iam_user_name   = "stanley"
iam_user_owner  = "stanley-nweke"
attach_admin_policy = true
