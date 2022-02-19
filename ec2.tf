resource "aws_iam_role_policy_attachment" cbio_portal_profile_role_policy_attachment {
  role       = aws_iam_role.cbio-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" cbio_portal_rofile_role_policy_attachment2 {
  role       = aws_iam_role.cbio-ec2-role.name
  policy_arn = data.aws_ssm_parameter.session_manager_policy_arn.value
}

resource "aws_iam_role" cbio-ec2-role {
  name = "${local.prefix}-cbioportal-ec2-profile-role"
  path = "/${local.prefix_path}/"
  assume_role_policy = data.aws_iam_policy_document.profile_assume_policy.json

  tags = merge(local.tags, {
    Name = "${local.prefix}-role"
  })
}

resource "aws_iam_instance_profile" cbio_instance_profile {
  name = "${local.prefix}-profile"
  role = aws_iam_role.cbio-ec2-role.name
  tags = merge(
  local.tags,
  {
    Name = "${local.prefix}-profile"
  }
  )
}

resource "aws_security_group" cbio_ec2_security_group {
  name = "${local.prefix}-sg"
  vpc_id = nonsensitive(data.aws_ssm_parameter.vpc_id.value)

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

resource "aws_instance" cbio_ec2 {
  ami = "ami-083ac7c7ecf9bb9b0"
  instance_type = var.instance_type
  user_data = "${file("pre_install.sh")}"
  subnet_id =  nonsensitive(split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0])
  vpc_security_group_ids = [aws_security_group.cbio_ec2_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.cbio_instance_profile.id
  root_block_device {
    volume_type = var.root_vol_type
    volume_size = var.root_vol_size
  }
  tags = merge(local.tags,{
    Name        = "${local.prefix}"
  })
}