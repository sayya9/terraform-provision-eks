data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.eks_vpc.id]
  }
}

resource "aws_eks_cluster" "eks" {
  name     = "${var.eks_name}"
  role_arn = aws_iam_role.eks.arn
  version  = "1.25"

  vpc_config {
    subnet_ids              = data.aws_subnets.all.ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy
  ]
}
