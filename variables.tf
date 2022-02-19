locals {
  DataProduct = "platform"
  Component   = "cbioportal"
  tags = {
    Environment     = var.account
    DataProduct     = local.DataProduct
    Component       = local.Component
  }
  prefix      = "${var.env}-${local.DataProduct}-${local.Component}"
  prefix_path = "${var.env}/${local.DataProduct}/${local.Component}"
  route53_domain_name = "data.guardanthealth.com"
}

variable aws_region {
  type = string
  description = "aws region"
  default = "us-west-2"
}

variable "account" {
  description = "This is the account where your infrastructure example - dpp, dpnp, dps"
  default     = "dpnp"
}

variable "env" {
  description = "This is the workspace where we will be creating the resource."
  default     = "dev"
}

variable "instance_type" {
  type    = string
  default = "r5.xlarge"
}

variable "root_vol_type" {
  type    = string
  default = "gp3"
}

variable "root_vol_size" {
  type    = number
  default = 1000
}

variable route53_create_alias {
  type    = string
  default = true
}