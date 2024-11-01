resource "aws_route53_zone" "main" {
  name = "rubyw.xyz"
}

variable "instance_port" {
  default = "8080"
}

resource "aws_iam_role" "cloudwatch_role" {
  name = "CloudWatchRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "CloudWatchPolicy"
  description = "A policy that allows EC2 to send metrics to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

resource "aws_iam_instance_profile" "cloudwatch_profile" {
  name = "CloudWatchProfile"
  role = aws_iam_role.cloudwatch_role.name
}

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
    Name = "${var.project_name}WebAppSecurityGroup"
  }
}

# Security Group for RDS
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-rds-sg"
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
  name   = "${var.project_name}-custom-postgres-params"
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
  iam_instance_profile   = aws_iam_instance_profile.cloudwatch_profile.name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 25
    delete_on_termination = true
  }

  user_data = <<-USERDATA
    #!/bin/bash
    
    apt-get update -y
    apt-get upgrade -y

    EC2_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

    touch /opt/csye6225/webapp/.env
    echo "DB_HOST=$(echo ${aws_db_instance.my_rds.endpoint} | cut -d':' -f1)" >> /opt/csye6225/webapp/.env
    echo "HOST=$${EC2_PUBLIC_IP}" >> /opt/csye6225/webapp/.env

    source /opt/csye6225/webapp/.env

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config \
        -m ec2 \
        -c file:/opt/csye6225/webapp/cloudwatch-config.json \
        -s


    sudo systemctl start amazon-cloudwatch-agent.service
    sudo systemctl enable amazon-cloudwatch-agent.service
    sudo systemctl status -l amazon-cloudwatch-agent.service

  USERDATA

  tags = {
    Name = "WebServerInstance"
  }
}

resource "aws_route53_record" "a_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "dev.rubyw.xyz"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web_server.public_ip]
}
