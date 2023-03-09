data "http" "my_ip" {
  url = "http://ipinfo.io/ip"
}

resource "aws_security_group" "sg_kops" {
  vpc_id      = aws_vpc.vpc.id
  name        = "KOPS SG"
  description = "PKOS Study KOPS SG"
}

resource "aws_security_group_rule" "sg_kops_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.my_ip.response_body)}/32"]
  security_group_id = aws_security_group.sg_kops.id
}

resource "aws_security_group_rule" "sg_kops_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_kops.id
}
