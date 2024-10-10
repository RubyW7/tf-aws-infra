resource "random_pet" "unique_suffix" {
  length = 2
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_instance" "example" {
    instance_type = "t2.micro" # error
}

resource "aws_instance" "example" {
    ami = "ami-12345678"  
   instance_type = "t2.micro"
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
