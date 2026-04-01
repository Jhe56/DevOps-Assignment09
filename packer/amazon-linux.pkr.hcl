packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0"
    }
  }
}

variable "public_key_path" {
  type = string
}

source "amazon-ebs" "ami" {
  region        = "us-east-1"
  instance_type = "t2.micro"
  ssh_username  = "ec2-user"

  ami_name = "devops-ami-{{timestamp}}"

  tags = {
    Name      = "prometheus-grafana"
    Project   = "Assignment09"
    CreatedBy = "packer"
  }

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
}

build {
  sources = ["source.amazon-ebs.ami"]

  provisioner "file" {
    source      = var.public_key_path
    destination = "/tmp/key.pub"
  }

  provisioner "shell" {
    script = "../scripts/ami-setup.sh"
  }
}
