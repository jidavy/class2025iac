terraform {
  backend  "local" {
   path = "/tmp/terraform.tfstate"
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


resource "aws_instance" "nginx-node" {
  ami                    = "ami-08b6a2983df6e9e25"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-060ba13bd6800a0db"
  vpc_security_group_ids = ["sg-090804d4ff518079d"]
  key_name               = "MasterClass2025"

  tags = {
    Name = "terraform-nginx-node"
  }
}
