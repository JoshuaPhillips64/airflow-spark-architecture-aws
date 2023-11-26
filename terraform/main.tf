# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      "Terraform"   = "true"
      "Environment" = "production"
    }
  }
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-west-2"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret access key"
  type        = string
  default     = ""
}

#Using the official VPC module from the Terraform Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"  # Specify the version you want to use

  name = "spark-airflow-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

}

# Security Group for Airflow EC2 Instance with Public Access
resource "aws_security_group" "all_ec2_sg" {
  name        = "airflow-sg"
  description = "Security group for Airflow EC2 instance with public access"
  vpc_id      = module.vpc.vpc_id

  # Ingress rule - Allows inbound traffic on port 8080 for Airflow web UI from any IP
  ingress {
    description = "Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule - Allow SSH access (port 22) from any IP (Not recommended for production)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Default egress rule - Allows all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_acl" "public_nacl" {
  vpc_id = module.vpc.vpc_id

  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"  // Restrict this for production environments
  }

}

resource "aws_network_acl_association" "public_nacl_association" {
  network_acl_id = aws_network_acl.public_nacl.id
  subnet_id      = module.vpc.public_subnets[0]  // Associate with the first public subnet
}

# EC2 Instance for Airflow
resource "aws_instance" "airflow" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.all_ec2_sg.id]
  associate_public_ip_address = true

  key_name = "streaming-architecture-key-pair"

  tags = {
    Name = "AirflowInstance"
  }

  user_data = file("${path.module}/../scripts/vm_setup.sh")
}

# EC2 Instance for Spark
resource "aws_instance" "spark" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.nano"
  subnet_id     = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.all_ec2_sg.id]
  associate_public_ip_address = true  # Ensure public IP is assigned

  user_data = file("${path.module}/../scripts/spark_instance_user_data.sh")

  key_name = "streaming-architecture-key-pair"

  tags = {
    Name = "SparkInstance"
  }
}

# Dynamically Fetching the Latest Amazon Linux AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# S3 Bucket for Data Storage
resource "aws_s3_bucket" "data_bucket" {
  bucket = "my-spark-data-bucket"

  tags = {
    Name        = "DataBucket"
    Environment = "Production"
  }
}


variable "bucket_name" {
  description = "Name of the S3 bucket for data storage"
  default     = "my-spark-data-bucket"
}



