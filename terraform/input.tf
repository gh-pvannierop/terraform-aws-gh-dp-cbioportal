locals {
  DataProduct = "platform"
  Component   = "CbioPortal"
  tags        = merge(var.tags, {
    Environment     = var.account
    DataProduct     = local.DataProduct
    Component       = local.Component
  }
  )
  prefix      = "${var.account}-${local.DataProduct}-${local.Component}"
  prefix_path = "${var.account}/${local.DataProduct}/${local.Component}"
}


#Common Variables
variable "aws_region" {
  description = "This is the cloud hosting region where your infrastructure will be deployed."
  default     = "us-west-2"
}

variable "account" {
  description = "This is the account where your infrastructure example - dpp, dpnp, dps"
  default     = "dpnp"
}

variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "tags" {
  description = "Optional map of tags to set on resources."
  type        = map
  default     = {}
}

## EC2 Variables

#   variable "name" {
#   type    = string
#   default = ""
# }

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
  default = "m4.xlarge"
}

# variable "ingress" {
#   type    = list(map(string))
#   default = []
# }

variable "whitelist_cidr" {
  type = list(string)
}

variable "root_vol_type" {
  type    = string
  default = "gp2"
}

variable "root_vol_size" {
  type    = number
  default = 30
}