# Terraform Configuration
# Data Engineering Infrastructure as Code

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.85"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Snowflake Provider
provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_username
  password = var.snowflake_password
  role     = "ACCOUNTADMIN"
}

# Kubernetes Provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prototyping"
}

variable "snowflake_account" {
  description = "Snowflake account identifier"
  type        = string
}

variable "snowflake_username" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password"
  type        = string
  sensitive   = true
}

# VPC Configuration
resource "aws_vpc" "data_engineering" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-data-engineering-vpc"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "data_engineering" {
  vpc_id = aws_vpc.data_engineering.id

  tags = {
    Name        = "${var.environment}-data-engineering-igw"
    Environment = var.environment
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.data_engineering.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.data_engineering.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.environment}-private-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# EKS Cluster
resource "aws_eks_cluster" "data_engineering" {
  name     = "${var.environment}-data-engineering"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.28"

  vpc_config {
    subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]

  tags = {
    Name        = "${var.environment}-data-engineering-eks"
    Environment = var.environment
  }
}

# EKS Node Group
resource "aws_eks_node_group" "data_engineering" {
  cluster_name    = aws_eks_cluster.data_engineering.name
  node_group_name = "${var.environment}-data-engineering-nodes"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]

  tags = {
    Name        = "${var.environment}-data-engineering-nodes"
    Environment = var.environment
  }
}

# RDS Instance for Airflow Metadata
resource "aws_db_instance" "airflow_metadata" {
  identifier = "${var.environment}-airflow-metadata"

  engine         = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = "airflow"
  username = "airflow"
  password = var.airflow_db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.data_engineering.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  skip_final_snapshot = true

  tags = {
    Name        = "${var.environment}-airflow-metadata"
    Environment = var.environment
  }
}

# S3 Bucket for DBT artifacts
resource "aws_s3_bucket" "dbt_artifacts" {
  bucket = "${var.environment}-dbt-artifacts-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.environment}-dbt-artifacts"
    Environment = var.environment
  }
}

# Random string for S3 bucket suffix
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# IAM roles and policies
resource "aws_iam_role" "eks_cluster" {
  name = "${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role" "eks_node_group" {
  name = "${var.environment}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# Security Groups
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-"
  vpc_id      = aws_vpc.data_engineering.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.data_engineering.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "data_engineering" {
  name       = "${var.environment}-data-engineering"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name        = "${var.environment}-data-engineering-db-subnet-group"
    Environment = var.environment
  }
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.data_engineering.id
}

output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.data_engineering.id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.data_engineering.endpoint
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.airflow_metadata.endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for DBT artifacts"
  value       = aws_s3_bucket.dbt_artifacts.bucket
}
