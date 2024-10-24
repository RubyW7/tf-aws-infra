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
