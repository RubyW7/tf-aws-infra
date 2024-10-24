resource "random_pet" "unique_suffix" {
  length = 2
}

data "aws_availability_zones" "available" {
  state = "available"
}

## from networking folder
module "networking" {
  source        = "./networking"
  project       = var.project
  region        = var.region
  vpc_cidr      = var.vpc_cidr
  unique_suffix = random_pet.unique_suffix.id
}

module "ec2" {
  source        = "./ec2"
  ami_id        = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = module.networking.public_subnet_ids[0]
  vpc_id        = module.networking.vpc_id
}

# Call the RDS Module
module "rds" {
  source                = "./rds"
  app_security_group_id = module.ec2.security_group_id
}