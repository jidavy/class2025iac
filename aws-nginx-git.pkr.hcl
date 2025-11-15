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
# source: how we build the AMI
#-----------------------------

source "amazon-ebs" "nginx-git" {
    region = "eu-west-1"
    instance_type = "t3.micro"
    ssh_username = "ec2-user"
    source_ami  = "ami-0870af38096a5355b"
    ami_name = "nginx-git-by-packer"
    ami_virtualization_type  = "hvm"
}

#------------------------------------
# build: source + provisioning to do 
#------------------------------------

build  {
    name  = "nginx-git-ami-build"
    sources = [
        "source.amazon-ebs.nginx-git" 
    ]

    provisioner "shell" {
        inline = [
            "sudo yum update -y",
            "sudo yum install nginx -y",
            "sudo systemctl enable nginx",
            "sudo systemctl start nginx",
            "echo  '<h1> Hello from Techbleat - Built by Packer </h1>' | sudo tee /usr/share/nginx/html/index.html",
            "sudo yum install git -y"
        ]
    }

    post-processor "shell-local" {
        inline = ["echo 'AMI build is finished' "]
    }

}


