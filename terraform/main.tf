resource "random_pet" "unique_suffix" {
  length = 2
}

resource "aws_instance" "example" {
  ami = "ami-123456"
  instance_type = "t2.micro"
  security_groups = ["sg-123456
}

data "aws_availability_zones" "available" {
  state = "available"
}

## from networking folder
module "networking" {
  source             = "./networking"
  project            = var.project
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  unique_suffix      = random_pet.unique_suffix.id
}
