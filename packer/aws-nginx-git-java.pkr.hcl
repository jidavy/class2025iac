packer {
    required_version = ">=1.9.0"

    required_plugins {
        amazon = {
            source  = "github.com/hashicorp/amazon"
            version = ">= 1.2.0"
        }
    }
}

# Variable to create a unique name for every build
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
    source_ami      = "ami-0870af38096a5355b"
    # Added timestamp so builds never collide
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
    source_ami      = "ami-0870af38096a5355b"
    # Added timestamp
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
            # Added Maven and Python3 to ensure the backend is ready to go
            "sudo yum install java-17-amazon-corretto maven python3 git -y"
        ]
    }
}
