terraform {
  # Temporarily disabled S3 backend due to permissions
  # backend "s3" {
  #   bucket  = "techbleat-cicd-state-bucket"
  #   key     = "envs/dev/terraform.tfstate"
  #   region  = "eu-west-1"
  #   encrypt = true
  # }
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
  description = "Allow SSH and Port 80 inbound, all outbound"
  vpc_id      = "vpc-0b8343f60d0d8ca1f"

  # Inbound SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP (port 80)
  ingress {
    description = "HTTP"
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
    Name = "nginx-security-group"
  }
}

# -------------------------
# Nginx EC2 Instance (Node 1)
# -------------------------
resource "aws_instance" "nginx_node" {
  ami                    = "ami-0d66888494d0c04fb" # TODO: Replace with your NGINX AMI from Packer
  instance_type          = "t2.micro"
  subnet_id              = "subnet-02f408ff476473c54"
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = "masterclass2025"

  user_data = <<-EOF
              #!/bin/bash
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "nginx-node"
  }
}

# -------------------------
# Python Node Security Group
# -------------------------
resource "aws_security_group" "python_sg" {
  name        = "python-sg"
  description = "Allow SSH and Port 8080 inbound, all outbound"
  vpc_id      = "vpc-0b8343f60d0d8ca1f"

  # Inbound SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound port 8080 (Python app)
  ingress {
    description = "Python App Port 8080"
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
    Name = "python-app-security-group"
  }
}

# -------------------------
# Python EC2 Instance (Node 2)
# -------------------------
resource "aws_instance" "python_node" {
  ami                    = "ami-0d93f6ccac1efd18a" # TODO: Replace with your Java/Python AMI from Packer
  instance_type          = "t2.micro"
  subnet_id              = "subnet-02f408ff476473c54"
  vpc_security_group_ids = [aws_security_group.python_sg.id]
  key_name               = "masterclass2025"

  user_data = <<-EOF
              #!/bin/bash
              # Start your Python app on port 8080
              # Add your application startup commands here
              # Example: cd /app && python3 app.py
              EOF

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

  # Inbound SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound port 9090 (Java app)
  ingress {
    description = "Java App Port 9090"
    from_port   = 9090
    to_port     = 9090
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
    Name = "java-security-group"
  }
}

# -------------------------
# Java EC2 Instance (Node 3)
# -------------------------
resource "aws_instance" "java_node" {
  ami                    = "ami-085e1e15a87b25f4c" # TODO: Replace with your Java/Python AMI from Packer (same as Python node)
  instance_type          = "t2.micro"
  subnet_id              = "subnet-02f408ff476473c54"
  vpc_security_group_ids = [aws_security_group.java_sg.id]
  key_name               = "masterclass2025"

  user_data = <<-EOF
              #!/bin/bash
              # Start your Java app on port 9090
              # Add your application startup commands here
              # Example: cd /app && java -jar app.jar
              EOF

  tags = {
    Name = "java-node"
  }
}

# -------------------------
# Outputs - Public IPs
# -------------------------
output "nginx_node_ip" {
  description = "NGINX Node Public IP (Port 80)"
  value       = aws_instance.nginx_node.public_ip
}

output "python_node_ip" {
  description = "Python Node Public IP (Port 8080)"
  value       = aws_instance.python_node.public_ip
}

output "java_node_ip" {
  description = "Java Node Public IP (Port 9090)"
  value       = aws_instance.java_node.public_ip
}

# Additional helpful output
output "access_instructions" {
  description = "How to access your services"
  value       = <<-EOT
  
  === Access Instructions ===
  NGINX:  http://${aws_instance.nginx_node.public_ip}
  Python: http://${aws_instance.python_node.public_ip}:8080
  Java:   http://${aws_instance.java_node.public_ip}:9090
  
  SSH Access:
  - NGINX:  ssh -i masterclass2025.pem ec2-user@${aws_instance.nginx_node.public_ip}
  - Python: ssh -i masterclass2025.pem ec2-user@${aws_instance.python_node.public_ip}
  - Java:   ssh -i masterclass2025.pem ec2-user@${aws_instance.java_node.public_ip}
  EOT
}