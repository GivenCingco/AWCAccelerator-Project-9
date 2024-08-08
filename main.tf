terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
#   backend "s3" {
#   bucket         = var.bucket_name
#   key            = var.key_name
#   region         = var.region_name
#   dynamodb_table = var.dynamodb_table_name
#   encrypt        = true
# }



  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = var.profile
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.bucket_name 
  force_destroy = true
}

# resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
#   bucket        = aws_s3_bucket.terraform_state.bucket 
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = var.dynamo_table_name
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }





/*Resource Block for VPC      */
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
   tags = {
    Name = "custom_vpc"
  }
}

/*Resource block for IGW */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id 

  tags = {
    Name = "custom_igw"
  }
}


/*==============================Public Resources====================*/

/*Public Route Table */
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

/*Public Subnet X2*/
resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.${count.index + 1}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-${count.index + 1}"
  }
}


/*Public Subnet X2 Route Table Association*/
resource "aws_route_table_association" "rta_public_subnet" {
  count = 2
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


/*==============================Private Resources====================*/

/*Public Route Table */
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Private-Route-Table"
  }
}

/*Private Subnet X4*/
resource "aws_subnet" "private_subnet" {
  count = 4
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.${count.index + 3}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name = "Private-Subnet-${count.index + 1}"
  }
}


/*Private Subnet X4 Route Table Association*/
resource "aws_route_table_association" "rta_private_subnet" {
  count          = 4
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}


