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
  region = "eu-west-1"
}

# -------------------------
# Web Node Security Group
# -------------------------

resource "aws_security_group" "web_sg" {

  name        = "web-sg"
  description = "Allow SSH and Port 80  inbound, all outbound"
  vpc_id      = var.project_vpc 


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
    description = "Web port 80"
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
    Name = "web-security_group"
  }

}

#-------------------------
# Web EC2 Instance
# ------------------------


resource "aws_instance" "web-node" {
  ami                    = var.project_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               =  var.project_keyname

  tags = {
    Name = "web-node"
  }
}

# Python backend setup

resource "aws_security_group" "python_sg" {

  name        = "python-sg"
  description = "Allow SSH and Port 9000  inbound, all outbound"
  vpc_id      = var.project_vpc


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
    from_port   = 9000
    to_port     = 9000
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
  ami                    = var.project_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.python_sg.id]
  key_name               =  var.project_keyname

  tags = {
    Name = "python-node"
  }
}


#--------------------------------
# Outputs - Public (external) IPs
#--------------------------------


output "web_node_ip" {
  description = " Public IP"
  value  = aws_instance.web-node.public_ip
}

output "python_node_ip" {
  description = " Public IP"
  value  = aws_instance.python-node.public_ip
}
