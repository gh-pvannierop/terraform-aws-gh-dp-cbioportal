provider "aws" {
  region = var.aws_region
  version = "~> 3.74.1"
}

provider "github" {
}

terraform {
  backend "s3" {
  }
}

resource "aws_iam_role_policy_attachment" jenkins_docker_instance_profile_role_policy_attachment {
  role       = aws_iam_role.cbio-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" jenkins_docker_instance_profile_role_policy_attachment2 {
  role       = aws_iam_role.cbio-ec2-role.name
  policy_arn = data.aws_ssm_parameter.session_manager_policy_arn.value
}

resource "aws_iam_role" "cbio-ec2-role" {
  name = "${local.prefix}-cbioportal-ec2-profile-role"
  path = "/${local.prefix_path}/"
  assume_role_policy = data.aws_iam_policy_document.profile_assume_policy.json

  tags = merge(local.tags, {
    Name = "${local.prefix}-role"
  })
}

resource "aws_iam_instance_profile" "cbio_instance_profile" {
  name = "${local.prefix}-profile"
  role = aws_iam_role.cbio-ec2-role.name
  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-profile"
    }
  )
}

resource "aws_security_group" "ec2_security_group" {
  name = "${local.prefix}-sg"
  vpc_id = data.aws_ssm_parameter.vpc_id

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

resource "aws_instance" "docker-daemon-server" {
  ami = "ami-083ac7c7ecf9bb9b0"
  instance_type = var.instance_type
  user_data = "${file("pre_install.sh")}"
  subnet_id =  nonsensitive(split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0])
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.cbio_instance_profile.id
  root_block_device {
    volume_type = var.root_vol_type
    volume_size = var.root_vol_size
  }
  tags = merge(local.tags,{
    Name        = "${local.prefix}-docker-daemon"
  })
}