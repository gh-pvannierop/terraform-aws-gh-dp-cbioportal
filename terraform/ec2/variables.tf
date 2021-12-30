locals {
  DataProduct = "platform"
  Component   = "CbioPortal"
  tags = {
    Environment     = var.account
    DataProduct     = local.DataProduct
    Component       = local.Component
  }
  prefix      = "${var.account}-${local.DataProduct}-${local.Component}"
  prefix_path = "${var.account}/${local.DataProduct}/${local.Component}"
  route53_domain_name = "data.guardanthealth.com"
}

variable "account" {
  type = string
}

# variable "domain_postfix" {
#   type = string
#   default = ""
# }

variable "aws_region" {
  type = string
}

# variable "name" {
#   type    = string
#   default = ""
# }

variable "vpc_id" {
  type        = string
  description = "ID of the host VPC"
}

variable "private_subnet_id" {
  type        = string
  description = "ID of the Private Subnet"
  default = ""
}

variable "public_subnet_id" {
  type        = string
  description = "ID of the Public Subnet"
  default = ""
}

variable "availability_zone" {
  type    = string
  default = "us-west-2a"
}

# variable "private_ip" {
#   type = string
# }



variable "ami" {
  type    = string
  default = "ami-04b762b4289fba92b"
  // Amazon Linux 2
}


variable "instance_type" {
  type    = string
  default = "r5.xlarge"
}

# variable "ingress" {
#   type    = list(map(string))
#   default = [
#     {
#       from_port   = 0
#       to_port     = 22
#       protocol    = "TCP"
#       description = "Allow SSH internally"
#       whitelist   = "10.63.0.0/16,10.4.0.0/16,10.112.0.0/21,50.233.156.5/32"
#     },
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "ICMP"
#       description = "Allow Ping from anywhere"
#       whitelist   = "10.4.0.0/16,10.112.0.0/21,10.6.0.0/16,100.64.0.0/16,100.22.0.0/16,100.67.0.0/16,10.8.0.0/16"
#     }
#   ]
# }

variable "whitelist_cidr" {
  type = list(string)
  default = []
}

variable "root_vol_type" {
  type    = string
  default = "gp2"
}

variable "root_vol_size" {
  type    = number
  default = 30
}