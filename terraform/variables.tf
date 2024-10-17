#variable
variable "region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name for tagging resources"
  type        = string
  default     = "myproject"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "The AMI to be used for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to deploy."
  default     = "t2.micro"
  type        = string
}

