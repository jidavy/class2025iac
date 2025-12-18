terraform {
  backend "local" {
     path = "/tmp/terraform/terraform.tfstate"
   }
  
  required_version = ">= 1.6.0"

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

#========================================
# SECURITY GROUPS
#========================================

# Web Node Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP (port 80)"
  vpc_id      = var.project_vpc

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "web-security-group"
  }
}

# Python Node Security Group
resource "aws_security_group" "python_sg" {
  name        = "python-sg"
  description = "Allow SSH and Python app (port 8080)"
  vpc_id      = var.project_vpc

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Python App"
    from_port   = 8080
    to_port     = 8080
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
    Name = "python-security-group"
  }
}

# Java Node Security Group
resource "aws_security_group" "java_sg" {
  name        = "java-sg"
  description = "Allow SSH and Java app (port 9090)"
  vpc_id      = var.project_vpc

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Java App"
    from_port   = 9090
    to_port     = 9090
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
    Name = "java-security-group"
  }
}

#========================================
# EC2 INSTANCES
#========================================

# Node 1: Web Server (NGINX)
resource "aws_instance" "web_node" {
  ami                    = var.nginx_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.project_keyname

  tags = {
    Name = "web-node-nginx"
    Tier = "Frontend"
  }
}

# Node 2: Python Backend
resource "aws_instance" "python_node" {
  ami                    = var.java_python_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.python_sg.id]
  key_name               = var.project_keyname

  tags = {
    Name = "python-node-backend"
    Tier = "Backend"
  }
}

# Node 3: Java Backend
resource "aws_instance" "java_node" {
  ami                    = var.java_python_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.java_sg.id]
  key_name               = var.project_keyname

  tags = {
    Name = "java-node-backend"
    Tier = "Backend"
  }
}

#========================================
# OUTPUTS
#========================================

output "web_node_public_ip" {
  description = "Web Node Public IP"
  value       = aws_instance.web_node.public_ip
}

output "python_node_public_ip" {
  description = "Python Node Public IP"
  value       = aws_instance.python_node.public_ip
}

output "java_node_public_ip" {
  description = "Java Node Public IP"
  value       = aws_instance.java_node.public_ip
}

output "web_url" {
  description = "Web Application URL"
  value       = "http://${aws_instance.web_node.public_ip}"
}

output "python_url" {
  description = "Python Application URL"
  value       = "http://${aws_instance.python_node.public_ip}:8080"
}

output "java_url" {
  description = "Java Application URL"
  value       = "http://${aws_instance.java_node.public_ip}:9090"
}
