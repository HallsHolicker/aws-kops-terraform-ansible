resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc_${var.study_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw_${var.study_name}"
  }
}

resource "aws_default_route_table" "rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "rt_${var.study_name}"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.kops_subnet_cidr
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "subnet_${var.study_name}"
  }
}

resource "aws_route_table_association" "rt_attach_subnet" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route" "igw_attach_subnet" {
  route_table_id         = aws_vpc.vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
