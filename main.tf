# main.tf - 调用 networking 模块

# 生成一个唯一后缀，防止资源名称冲突
resource "random_pet" "unique_suffix" {
  length = 2
}

# 调用 networking 模块
module "networking" {
  source             = "./networking"
  project            = var.project
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  unique_suffix      = random_pet.unique_suffix.id
}
