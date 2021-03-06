#Terraform Configuraiton

provider "aws" {
  region = var.aws_region
  version = "~> 3.74.1"   
}

# Configure the GitHub Provider
provider "github" {
}

terraform {
  backend "s3" {
  }
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.account}/${local.DataProduct}/network/private_subnet_ids"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.account}/${local.DataProduct}/network/public_subnet_ids"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.account}/${local.DataProduct}/network/vpc_id"
}

module "ec2" {
  source                       = "./ec2"
  aws_region                   = var.aws_region
  account                      = var.account 
  ami                          = var.ami
  instance_type                = var.instance_type
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  public_subnet_id             = element(split(",",data.aws_ssm_parameter.public_subnet_ids.value),0)
  #private_subnet_id            = element(split(",",data.aws_ssm_parameter.private_subnet_ids.value),0)
  #private_ip                   = var.private_ip
  root_vol_size                = var.root_vol_size
  root_vol_type                = var.root_vol_type
  whitelist_cidr               = var.whitelist_cidr
  env                          = var.env
}
