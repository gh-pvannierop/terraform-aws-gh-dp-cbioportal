# locals {
#   availability_zone = "${var.aws_region}a"
# }

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

# data "aws_subnet" "private_subnet" {
#   id = var.private_subnet_id
# }

data "aws_subnet" "public_subnet" {
  id = var.public_subnet_id
}

/*
  Security Groups
*/
resource "aws_security_group" "sg" {
  name = "${local.prefix}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    description = "Allow SSH"
    cidr_blocks   = var.whitelist_cidr
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = "Allow HTTP"
    cidr_blocks   = var.whitelist_cidr
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description = "Allow HTTPS"
    cidr_blocks   = var.whitelist_cidr
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    description = "Allow Ping from anywhere"
    cidr_blocks   = var.whitelist_cidr
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = "Internet connection"
  }

  tags = merge(local.tags, {
      Name = "${local.prefix}-sg"
    })
}

resource "aws_iam_instance_profile" "profile" {
  name = "${local.prefix}-profile"
  role = aws_iam_role.role.name
  tags = merge(local.tags, {
      Name = "${local.prefix}-profile"
    }
  )
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

resource "aws_iam_role" "role" {
  name = "${local.prefix}-profile"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.profile_assume_policy.json

  tags = merge(local.tags, {
      Name = "${local.prefix}-role"
    })
}

resource "aws_iam_role_policy_attachment" ec2_instance_profile_role_policy_attachment {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data aws_ssm_parameter "session_manager_policy_arn" {
  name = "/${var.account}/security/session-manager/policy_arn"
}

resource "aws_iam_role_policy_attachment" jenkins_docker_instance_profile_role_policy_attachment2 {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_ssm_parameter.session_manager_policy_arn.value
}

#Create key pair and store in secret manager
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${local.prefix}-ec2-key"
  public_key = tls_private_key.key.public_key_openssh

  tags = merge(local.tags, {
      Name = "${local.prefix}-ec2-key_pair"
    })
}

resource "aws_secretsmanager_secret" "key" {
  name = "${prefix_path}/ec2/key_pair"
}

resource "aws_secretsmanager_secret_version" "key" {
  secret_id     = aws_secretsmanager_secret.key.id
  secret_string = tls_private_key.key.private_key_pem
}

resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]
  subnet_id                  = data.aws_subnet.public_subnet.id
  iam_instance_profile       = aws_iam_instance_profile.profile.name
  #private_ip                 = var.private_ip

  key_name                   = aws_key_pair.generated_key.key_name

  root_block_device {
    volume_type = var.root_vol_type
    volume_size = var.root_vol_size
  }

  tags = merge(local.tags, {
      Name = "${local.prefix}-ec2"
    })
}

resource "aws_eip" "eip" {
  instance = aws_instance.ec2.id
  vpc      = true

  tags = merge(local.tags, {
      Name = "${local.prefix}-ec2-eip"
    })
}

