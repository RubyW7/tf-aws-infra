# Security Group for RDS
resource "aws_security_group" "db_sg" {
  name        = "myapp-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB Subnet Group"
  }
}

resource "aws_db_parameter_group" "custom_postgres_params" {
  name   = "custom-postgres-params"
  family = "postgres16"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = {
    Name = "Custom PostgreSQL Parameter Group"
  }
}


# RDS Instance
resource "aws_db_instance" "rds_instance" {
  identifier             = "csye6225"
  engine                 = "postgres"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  username = "csye6225"
  password = "password"
  db_name  = "csye6225"

  multi_az            = false
  publicly_accessible = false

  parameter_group_name = aws_db_parameter_group.custom_postgres_params.name
  skip_final_snapshot  = true

  tags = {
    Name = "rds-instance"
  }
}