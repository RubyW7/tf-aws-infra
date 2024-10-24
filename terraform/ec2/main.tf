resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-application-security-group"
  description = "Security group for EC2 instances hosting web applications"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebAppSecurityGroup"
  }
}

# Security Group for RDS
resource "aws_security_group" "db_sg" {
  name        = "myapp-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDSSecurityGroup"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
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

resource "aws_db_instance" "my_rds" {
  allocated_storage     = 20
  max_allocated_storage = 100
  engine                = "postgres"
  instance_class        = "db.t3.micro"
  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password
  parameter_group_name  = aws_db_parameter_group.custom_postgres_params.name
  db_subnet_group_name  = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot   = true

  vpc_security_group_ids = [aws_security_group.db_sg.id]

  multi_az            = false
  publicly_accessible = false
  tags = {
    Name = "MyRDSInstance"
  }
}

resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 25
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    
    apt-get update -y
    apt-get upgrade -y

    touch /opt/csye6225/.env
    echo "DB_HOST='${aws_db_instance.my_rds.endpoint}'" >> /opt/csye6225/webapp/.env
    echo "DB_USER='csye6225'" >> /etc/environment >> /opt/csye6225/webapp/.env
    echo "DB_PASSWORD='Wyd0718520'" >> /opt/csye6225/webapp/.env
    echo "DB_NAME='csye6225'" >> /opt/csye6225/webapp/.env
    echo "DB_PORT='5432'" >> /opt/csye6225/webapp/.env

    source /opt/csye6225/.env

  EOF


  tags = {
    Name = "WebServerInstance"
  }
}
