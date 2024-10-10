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

resource "random_id" "this" {
  keepers = {    # This opening brace should be on the next line to trigger a fmt error
  id = "some-id"
  }

  # This will cause a validation error because 'byte_length' is mandatory and not provided
};;