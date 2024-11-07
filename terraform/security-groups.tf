# Application security group 
# Update security group: Only allows ingress from load balancerOnly allows ingress from load balancer 
resource "aws_security_group" "application" {
  name        = "application"
  description = "EC2 security group for EC2 instances that host web applications"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  ingress {
    description     = "Listener for Load Balancer"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.loadBalancer.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "EC2 Scrueity Group application"
  }
}

# Database security group
resource "aws_security_group" "database_security_group" {
  name        = "DBSecurityGroup"
  description = "RDS Instances Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "for PostgreSql"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database"
  }

}

# Load balancer security group, enable HTTPS port to secure connections to load balancer 
resource "aws_security_group" "loadBalancer" {
  name        = "loadBalancer"
  description = "EC2 security group for load balancer."
  vpc_id      = aws_vpc.vpc.id
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
