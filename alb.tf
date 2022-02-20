resource "aws_security_group_rule" "alb_ingress_all" {
  type = "ingress"
  protocol = "all"
  from_port = 0
  to_port = 0
  security_group_id = aws_security_group.alb_security_group.id

  self = true
}

resource "aws_security_group_rule" "alb_ingress_443" {
  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_blocks = local.github_ip_ranges_ipv4_cidr
  ipv6_cidr_blocks = local.github_ip_ranges_ipv6_cidr
  description = "Open CBIO Port for specific address"
  security_group_id = aws_security_group.alb_security_group.id
}

resource "aws_security_group" alb_security_group {
  name        = "${local.prefix}-alb"
  description = "${local.prefix} alb security group"
  vpc_id      = nonsensitive(data.aws_ssm_parameter.vpc_id.value)

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags,{
    Name        = "${local.prefix}-alb"
  })
}

resource "aws_lb_target_group" alb_target {
  name        = replace("${local.prefix}-crtl", "_", "-")
  port        = "8080"
  protocol    = "HTTP"
  vpc_id      = nonsensitive(data.aws_ssm_parameter.vpc_id.value)
  target_type = "ip"

  health_check {
    enabled = true
    path    = "/login"
  }

  tags = merge(local.tags,{
    Name        = "${local.prefix}-crtl-tgt-group"
  })
  depends_on = [aws_lb.cbio_alb]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" cbio_alb {
  name               = replace("${local.prefix}-crtl-alb", "_", "-")
  internal           = true
  load_balancer_type = "application"
  security_groups    = concat(nonsensitive(split(",", data.aws_ssm_parameter.vpn_sg.value)), [aws_security_group.alb_security_group.id])
  subnets            = nonsensitive(split(",", data.aws_ssm_parameter.public_subnet_ids.value))

  enable_deletion_protection = true

  access_logs {
    bucket  = data.aws_ssm_parameter.s3_logging_id.value
    prefix  = "alb/${local.prefix}"
    enabled = true
  }

  tags = merge(local.tags,{
    Name        = "${local.prefix}-crtl-alb"
  })
}

resource "aws_lb_listener" alb_listner {
  load_balancer_arn = aws_lb.cbio_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = nonsensitive(data.aws_ssm_parameter.certificate_arn.value)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target.arn
  }
}