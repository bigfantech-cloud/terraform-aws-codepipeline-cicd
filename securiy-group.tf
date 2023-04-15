resource "aws_security_group" "codebuild_sg" {
  count = var.codebuild_inside_vpc ? 1 : 0

  name        = "${module.this.id}-codebuild"
  description = "Allow access to codebuild"
  vpc_id      = var.vpc_id

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}-codebuild"
    },
  )
}

resource "aws_security_group_rule" "egress" {
  count = var.codebuild_inside_vpc ? 1 : 0

  security_group_id = aws_security_group.codebuild_sg[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress" {
  count = var.codebuild_inside_vpc ? 1 : 0

  security_group_id = aws_security_group.codebuild_sg[0].id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

