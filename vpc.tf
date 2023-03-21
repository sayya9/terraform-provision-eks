resource "aws_vpc" "eks_vpc" {
  cidr_block       = "${var.eks_vpc_cidr}"
  instance_tenancy = "default"

  tags = {
    Name = "eks_vpc"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.eks_name}-igw"
  }
}

resource "aws_subnet" "eks_public_subnets" {
  for_each = var.eks_public_subnets

  vpc_id     =  aws_vpc.eks_vpc.id
  cidr_block = each.value["cidr"]
  availability_zone = each.value["az"]

  tags = {
    Name = "${var.eks_name}-${each.key}"
    "kubernetes.io/cluster/${var.eks_name}"= "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id =  aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "${var.eks_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.eks_public_subnets)

  subnet_id      = aws_subnet.eks_public_subnets["public-subnet-${count.index+1}"].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  count = length(var.eks_private_subnets)

  vpc = true

  tags = {
    Name = "${var.eks_name}-eip-${count.index+1}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(var.eks_private_subnets)

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.eks_public_subnets["public-subnet-${count.index+1}"].id

  tags = {
    Name = "${var.eks_name}-nat-${count.index+1}"
  }
}

resource "aws_subnet" "eks_private_subnets" {
  for_each = var.eks_private_subnets

  vpc_id     =  aws_vpc.eks_vpc.id
  cidr_block = each.value["cidr"]
  availability_zone = each.value["az"]

  tags = {
    Name = "${var.eks_name}-${each.key}"
    "kubernetes.io/cluster/${var.eks_name}"= "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table" "private_rt" {
  count = length(var.eks_private_subnets)

  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "${var.eks_name}-private-rt-${count.index+1}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.eks_private_subnets)

  subnet_id      = aws_subnet.eks_private_subnets["private-subnet-${count.index+1}"].id
  route_table_id = aws_route_table.private_rt[count.index].id
}
