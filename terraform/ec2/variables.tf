variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group will be created"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the EC2 instance will be launched"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The type of instance to launch"
}

variable "app_port" {
  type        = number
  default     = 8080
  description = "The application port that the security group should allow"
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

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "myapp"
}