variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Prefix for resource names"
  default     = "assignment09"
}

variable "my_ip" {
  type        = string
  description = "YOUR PUBLIC IP/32"
}

variable "key_name" {
  type        = string
  description = "assignment08-key"
}

variable "custom_ami_id" {
  type        = string
  description = "YOUR AMI ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}
