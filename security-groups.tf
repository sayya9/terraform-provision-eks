resource "aws_security_group" "additional" {
  name        = "${var.eks_name}-additional-sg"
  description = ""
  vpc_id      = aws_vpc.eks_vpc.id
}

resource "aws_security_group_rule" "additional" {
  description       = "Allow internal traffic"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.additional.id
}

resource "aws_security_group_rule" "allow_all" {
  description       = ""
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.additional.id
}
