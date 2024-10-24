resource "random_pet" "unique_suffix" {
  length = 2
}

data "aws_availability_zones" "available" {
  state = "available"
}

# create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-${var.unique_suffix}-vpc"
  }
}

# create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project}-${var.unique_suffix}-igw"
  }
}

# create public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-${var.unique_suffix}-public-rt"
  }
}

# create private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project}-${var.unique_suffix}-private-rt"
  }
}

# create public subnet
resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project}-${var.unique_suffix}-public-subnet-${count.index + 1}"
  }
}

# create private subnet
resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project}-${var.unique_suffix}-private-subnet-${count.index + 1}"
  }
}

# association
resource "aws_route_table_association" "public_association" {
  count          = 3
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_association" {
  count          = 3
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}
