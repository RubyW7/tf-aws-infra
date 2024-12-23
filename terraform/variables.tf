variable "profile" {
  description = "provider profile name"
  default     = "dev"
}
variable "vpc_name" {
  description = "VPC name tag"
  default     = "vpc-1"
}

variable "DYNAMO_DB_TABLE_NAME" {
  default     = "csye6225"
}

variable "SNS_TOPIC_ARN" {
  default     = "arn:aws:sns:us-east-1:703671935232:csye6225-SNSTopic"
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_region" {
  description = "VPC AWS region"
  default     = "ca-central-1"
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  default     = ["a", "b", "d"]
}

variable "ami" {
  description = "ID of the Amazon Machine Image (AMI) to use"
}

variable "key_name" {
  description = "key pair for instance"
}

variable "environment" {
  description = "environment name"
}

variable "db_username" {
  description = "rds username"
  default     = "csye6225"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "csye6225"
}

variable "subdomain_name" {
  description = "subdomain record name"
}

variable "subdomain_ns_ttl" {
  description = "ttl (seconds) for hosted zone record"
  default     = "300"
}

variable "MAILGUN_API_KEY" {
  description = "MAILGUN_API_KEY"
  type        = string
}

variable "MAILGUN_DOMAIN" {
  description = "MAILGUN_DOMAIN"
  type        = string
}
