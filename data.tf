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

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.account}/platform/network/public_subnet_ids"
}

data "aws_ssm_parameter" "vpn_sg" {
  name = "/${var.account}/platform/network/vpn_sg"
}

data "aws_ssm_parameter" "s3_logging_id" {
  name = "/${var.account}/security/account/alb_logging_id"
}

data "aws_ssm_parameter" "certificate_arn" {
  name = "/${var.account}/platform/domain/certificate_arn"
}

data "aws_ssm_parameter" "data_zone_id" {
  name = "/${var.account}/platform/domain/zone_id"
}