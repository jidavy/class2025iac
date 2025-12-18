packer {
    required_version = ">=1.9.0"

    required_plugins {
        amazon = {
            source = "github.com/hashicorp/amazon"
            version = ">= 1.2.0"
        }
    }
}

#-----------------------------
# SOURCE 1: NGINX + Git AMI
#-----------------------------
source "amazon-ebs" "nginx-git" {
    region                  = "eu-west-1"
    instance_type           = "t3.micro"
    ssh_username            = "ec2-user"
    source_ami              = "ami-0c38b837cd80f13bb"  # Amazon Linux 2023
    ami_name                = "nginx-git-ami-{{timestamp}}"
    ami_description         = "NGINX web server with Git"
    ami_virtualization_type = "hvm"
    
    tags = {
        Name = "nginx-git-ami"
        Created = "Packer"
    }
}

#-----------------------------
# SOURCE 2: Java + Python + Git AMI
#-----------------------------
source "amazon-ebs" "java-python-git" {
    region                  = "eu-west-1"
    instance_type           = "t3.micro"
    ssh_username            = "ec2-user"
    source_ami              = "ami-0c38b837cd80f13bb"  # Amazon Linux 2023
    ami_name                = "java-python-git-ami-{{timestamp}}"
    ami_description         = "Java 17 and Python 3 with Git"
    ami_virtualization_type = "hvm"
    
    tags = {
        Name = "java-python-git-ami"
        Created = "Packer"
    }
}

#------------------------------------
# BUILD 1: NGINX + Git
#------------------------------------
build {
    name = "nginx-git-ami-build"
    sources = [
        "source.amazon-ebs.nginx-git"
    ]

    provisioner "shell" {
        inline = [
            "echo '=== Updating system ==='",
            "sudo yum update -y",
            
            "echo '=== Installing NGINX ==='",
            "sudo yum install nginx -y",
            
            "echo '=== Configuring NGINX ==='",
            "sudo systemctl enable nginx",
            "sudo systemctl start nginx",
            
            "echo '=== Creating test page ==='",
            "echo '<h1>Hello from Techbleat - NGINX by Packer</h1>' | sudo tee /usr/share/nginx/html/index.html",
            
            "echo '=== Installing Git ==='",
            "sudo yum install git -y",
            
            "echo '=== Verifying installations ==='",
            "nginx -v",
            "git --version"
        ]
    }

    post-processor "shell-local" {
        inline = [
            "echo '✅ NGINX + Git AMI build completed successfully!'"
        ]
    }
}

#------------------------------------
# BUILD 2: Java 17 + Python 3 + Git
#------------------------------------
build {
    name = "java-python-git-ami-build"
    sources = [
        "source.amazon-ebs.java-python-git"
    ]

    provisioner "shell" {
        inline = [
            "echo '=== Updating system ==='",
            "sudo yum update -y",
            
            "echo '=== Installing Java 17 ==='",
            "sudo yum install java-17-amazon-corretto -y",
            
            "echo '=== Installing Python 3 ==='",
            "sudo yum install python3 python3-pip -y",
            
            "echo '=== Installing Git ==='",
            "sudo yum install git -y",
            
            "echo '=== Verifying installations ==='",
            "java -version",
            "python3 --version",
            "pip3 --version",
            "git --version"
        ]
    }

    post-processor "shell-local" {
        inline = [
            "echo '✅ Java + Python + Git AMI build completed successfully!'"
        ]
    }
}
