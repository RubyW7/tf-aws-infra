resource "random_pet" "unique_suffix" {
  length = 2
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

module "ec2" {
  source       = "./ec2"                       
  ami_id       = var.ami_id                    
  instance_type = var.instance_type            
  subnet_id    = module.networking.public_subnet_ids[0]   
  vpc_id       = module.networking.vpc_id      
}                

# Call the RDS Module
module "rds" {
  source               = "./rds"
  db_instance_class    = var.db_instance_class
  db_engine            = var.db_engine
  db_password          = var.db_password
  db_subnet_group_name = module.networking.db_subnet_group
  vpc_id               = module.networking.vpc_id
  app_security_group_id = module.ec2.security_group_id # Assuming the EC2 module outputs the security group ID
}