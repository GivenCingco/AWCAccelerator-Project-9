terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  backend "s3" {
    bucket         = "given-cingco-devops-directive-tf-state" # REPLACE WITH YOUR BUCKET NAME
    key            = "project#9/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "given-cingco-devops-directive-tf-state" # REPLACE WITH YOUR BUCKET NAME
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket        = aws_s3_bucket.terraform_state.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}





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

/*Public Subnet 1*/
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-1"
  }
}

/*Public Subnet 2*/
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true


  tags = {
    Name = "Public-Subnet-2"
  } 
}

/*Public Subnet 1 Route Table Association*/
resource "aws_route_table_association" "rta_public_subnet_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

/*Public Subnet 2 Route Table Association*/
resource "aws_route_table_association" "rta_public_subnet_2" {
  subnet_id = aws_subnet.public_subnet_2.id
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

/*Private Subnet 1*/
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-Subnet-1"
  }
}

/*Private Subnet 2*/
resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"


  tags = {
    Name = "Private-Subnet-2"
  } 
}

/*Private Subnet 3*/
resource "aws_subnet" "private_subnet_3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1a"


  tags = {
    Name = "Private-Subnet-3"
  } 
}

/*Private Subnet 4*/
resource "aws_subnet" "private_subnet_4" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-east-1b"


  tags = {
    Name = "Private-Subnet-4"
  } 
}

/*Private Subnet 1 Route Table Association*/
resource "aws_route_table_association" "rta_private_subnet_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

/*Private Subnet 2 Route Table Association*/
resource "aws_route_table_association" "rta_private_subnet_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

/*Private Subnet 3 Route Table Association*/
resource "aws_route_table_association" "rta_private_subnet_3" {
  subnet_id = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_rt.id
}

/*Private Subnet 4 Route Table Association*/
resource "aws_route_table_association" "rta_private_subnet_4" {
  subnet_id = aws_subnet.private_subnet_4.id
  route_table_id = aws_route_table.private_rt.id
}
