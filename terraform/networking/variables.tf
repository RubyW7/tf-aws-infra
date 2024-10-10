variable "project" {
  description = "Project name for tagging resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "unique_suffix" {
  description = "Unique suffix for resource names"
  type        = string
}
