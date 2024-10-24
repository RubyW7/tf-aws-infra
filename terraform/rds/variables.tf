variable "vpc_id" {
  description = "VPC ID where the RDS and security groups reside"
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID for the application"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "csye6225"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  default     = "password"
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "csye6225"
}