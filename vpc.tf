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
  for_each = var.eks_public_subnets

  subnet_id 		 = aws_subnet.eks_public_subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}
