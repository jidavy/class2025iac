terraform {
  # Temporarily disabled S3 backend due to permissions
  # backend "s3" {
  # bucket  = "techbleat-cicd-state-bucket"
  # key     = "envs/dev/terraform.tfstate"
  # region  = "eu-west-1"
  # encrypt = true

  #}
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# -------------------------
# Nginx Node Security Group
# -------------------------

resource "aws_security_group" "nginx_sg" {

  name        = "nginx-sg"
  description = "Allow SSH and Port 80  inbound, all outbound"
  vpc_id      = "vpc-0b8343f60d0d8ca1f"


  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 80 (web)
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-security_group"
  }

}

#-------------------------
# nginx EC2 Instance
# ------------------------


resource "aws_instance" "nginx-node" {
  ami                    = "ami-08b6a2983df6e9e25"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-02f408ff476473c54"
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = "masterclass2025"

  tags = {
    Name = "nginx-node"
  }
}

# Python backend setup

resource "aws_security_group" "python_sg" {

  name        = "python-sg"
  description = "Allow SSH and Port 8080 inbound, all outbound"
  vpc_id      = "vpc-0b8343f60d0d8ca1f"


  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 9000 (app)
  ingress {
    description = "Python App port 9000"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "python-app-security_group"
  }

}

#-------------------------
# Python EC2 Instance
# ------------------------


resource "aws_instance" "python-node" {
  ami                    = "ami-08b6a2983df6e9e25"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-02f408ff476473c54"
  vpc_security_group_ids = [aws_security_group.python_sg.id]
  key_name               = "masterclass2025"

  tags = {
    Name = "python-node"
  }
}

# -------------------------
# Java Node Security Group
# -------------------------
resource "aws_security_group" "java_sg" {
  name        = "java-sg"
  description = "Allow SSH and Port 9090 inbound, all outbound"
  vpc_id      = "vpc-0b8343f60d0d8ca1f"

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

# -------------------------
# Java EC2 Instance (Node 3)
# -------------------------
resource "aws_instance" "java_node" {
  ami                    = "ami-08b6a2983df6e9e25"  # Replace with your Java AMI from Packer
  instance_type          = "t2.micro"
  subnet_id              = "subnet-02f408ff476473c54"
  vpc_security_group_ids = [aws_security_group.java_sg.id]
  key_name               = "masterclass2025"

  tags = {
    Name = "java-node"
  }
}


#--------------------------------
# Outputs - Public (external) IPs
#--------------------------------


output "web_node_ip" {
  description = " NGINX Node Public IP"
  value  = aws_instance.nginx-node.public_ip
}

output "python_node_ip" {
  description = "Python Node Public IP (Port 8080)"
  value  = aws_instance.python-node.public_ip
}

output "java_node_ip" {
  description = "Java Node Public IP (Port 9090)"
  value       = aws_instance.java_node.public_ip
}