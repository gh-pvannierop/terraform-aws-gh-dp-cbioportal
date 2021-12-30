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

variable "env" {
  type = string
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
  default = "ami-083ac7c7ecf9bb9b0"
  // Amazon Linux 2
}

variable "instance_type" {
  type    = string
  default = "r5.xlarge"
}

# variable "ingress" {
#   type    = list(map(string))
#   default = []
# }

variable "whitelist_cidr" {
  type = list(string)
  default = [

  // Global Protect VPN
  "10.112.0.0/21",
  "10.117.0.0/16",

  // OnPrem
  "10.4.0.0/16", // Redwood City 505
  "10.12.0.0/16" // Redwood City 220
]
}

variable "root_vol_type" {
  type    = string
  default = "gp3"
}

variable "root_vol_size" {
  type    = number
  default = 1000
}