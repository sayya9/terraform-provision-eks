data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.eks_vpc.id]
  }

  depends_on = [
    aws_subnet.eks_public_subnets,
    aws_subnet.eks_private_subnets
  ]
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
    aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceController
  ]
}

data "tls_certificate" "cert" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
