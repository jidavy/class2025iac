variable "project_vpc" {
  description = "VPC ID for the infrastructure"
  type        = string
}

variable "nginx_ami" {
  description = "AMI ID for NGINX web server"
  type        = string
}

variable "java_python_ami" {
  description = "AMI ID for Java and Python backends"
  type        = string
}

variable "project_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "project_subnet" {
  description = "Subnet ID for instances"
  type        = string
}

variable "project_keyname" {
  description = "SSH key pair name"
  type        = string
}
