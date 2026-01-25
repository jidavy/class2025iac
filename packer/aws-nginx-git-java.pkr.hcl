packer {
    required_version = ">=1.9.0"

    required_plugins {
        amazon = {
            source  = "github.com/hashicorp/amazon"
            version = ">= 1.2.0"
        }
    }
}

variable "timestamp" {
    type    = string
    default = "{{timestamp}}"
}

#-----------------------------
# source: Nginx Frontend
#-----------------------------
source "amazon-ebs" "nginx-git" {
    region          = "eu-west-1"
    instance_type   = "t3.micro"
    ssh_username    = "ec2-user"
    
    # DYNAMIC FILTER instead of hardcoded ID
    source_ami_filter {
        filters = {
            name                = "al2023-ami-2023.*-x86_64"
            root-device-type    = "ebs"
            virtualization-type = "hvm"
        }
        most_recent = true
        owners      = ["137112412989"] # Amazon's Official Account ID
    }

    ami_name        = "nginx-git-by-packer-${var.timestamp}"
    ami_virtualization_type = "hvm"
}

#-----------------------------
# source: Java/Python Backend
#-----------------------------
source "amazon-ebs" "java-git" {
    region          = "eu-west-1"
    instance_type   = "t3.micro"
    ssh_username    = "ec2-user"

    # DYNAMIC FILTER instead of hardcoded ID
    source_ami_filter {
        filters = {
            name                = "al2023-ami-2023.*-x86_64"
            root-device-type    = "ebs"
            virtualization-type = "hvm"
        }
        most_recent = true
        owners      = ["137112412989"]
    }

    ami_name        = "java-git-by-packer-${var.timestamp}"
    ami_virtualization_type = "hvm"
}

#------------------------------------
# build: Nginx
#------------------------------------
build {
    name    = "nginx-git-ami-build"
    sources = ["source.amazon-ebs.nginx-git"]

    provisioner "shell" {
        inline = [
            "sudo yum update -y",
            "sudo yum install nginx git -y",
            "sudo systemctl enable nginx",
            "echo '<h1> Hello from Techbleat - Built by Packer </h1>' | sudo tee /usr/share/nginx/html/index.html"
        ]
    }
}

#------------------------------------
# build: Java & Python
#------------------------------------
build {
    name    = "java-git-ami-build"
    sources = ["source.amazon-ebs.java-git"]

    provisioner "shell" {
        inline = [
            "sudo yum update -y",
            "sudo yum install java-17-amazon-corretto maven python3 git -y"
        ]
    }
}
