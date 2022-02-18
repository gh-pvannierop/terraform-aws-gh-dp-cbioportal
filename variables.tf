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

locals {
  DataProduct = "platform"
  Component   = "cbioportal"
  tags = {
    Environment     = var.env
    DataProduct     = local.DataProduct
    Component       = local.Component
  }
  prefix      = "${var.account}-${local.DataProduct}-${local.Component}"
  prefix_path = "${var.account}/${local.DataProduct}/${local.Component}"
  route53_domain_name = "data.guardanthealth.com"
}

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

data aws_ssm_parameter "session_manager_policy_arn" {
  name = "/${var.account}/security/session-manager/policy_arn"
}

data aws_iam_policy_document profile_assume_policy {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
    sid = "AllowEC2Assume"
  }
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.account}/platform/network/vpc_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.account}/platform/network/private_subnet_ids"
}