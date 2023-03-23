data "aws_subnets" "eks_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.eks_vpc.id]
  }

  tags = {
    Name = "*private*"
  }

  depends_on = [
    aws_subnet.eks_private_subnets
  ]
}

data "aws_instances" "stateful" {
  instance_tags = {
    "eks:nodegroup-name" = "${var.eks_name}-stateful"
  }

  filter {
    name   = "vpc-id"
    values = [aws_vpc.eks_vpc.id]
  }

  instance_state_names = ["running", "pending"]

  depends_on = [
    aws_eks_node_group.stateful
  ]
}

data "aws_instances" "spot" {
  instance_tags = {
    "eks:nodegroup-name" = "${var.eks_name}-spot"
  }

  filter {
    name   = "vpc-id"
    values = [aws_vpc.eks_vpc.id]
  }

  instance_state_names = ["running", "pending"]

  depends_on = [
    aws_eks_node_group.spot
  ]
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "stateful" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.eks_name}-stateful"
  version         = aws_eks_cluster.eks.version
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = data.aws_subnets.eks_private_subnets.ids
  ami_type        = "AL2_x86_64"
  capacity_type   = "ON_DEMAND"
  disk_size       = 30
  instance_types  = ["t2.medium"]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes_AmazonEC2ContainerRegistryReadOnly
  ]
}

resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.eks_name}-spot"
  version         = aws_eks_cluster.eks.version
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = data.aws_subnets.eks_private_subnets.ids
  ami_type        = "AL2_x86_64"
  capacity_type   = "SPOT"
  disk_size       = 30
  instance_types  = ["t2.medium"]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes_AmazonEC2ContainerRegistryReadOnly
  ]
}

resource "aws_autoscaling_group_tag" "stateful" {    
  autoscaling_group_name = aws_eks_node_group.stateful.resources[0].autoscaling_groups[0].name

  tag {
    key   = "Name"
    value = "${var.eks_name}-stateful"

    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_node_group.stateful
  ]
}

resource "aws_autoscaling_group_tag" "spot" {    
  autoscaling_group_name = aws_eks_node_group.spot.resources[0].autoscaling_groups[0].name

  tag {
    key   = "Name"
    value = "${var.eks_name}-spot"

    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_node_group.spot
  ]
}

resource "aws_ec2_tag" "stateful" {
  count = var.desired_size

  resource_id = data.aws_instances.stateful.ids[count.index]
  key         = "Name"
  value       = "${var.eks_name}-stateful"

  depends_on = [
    aws_eks_node_group.stateful
  ]
}

resource "aws_ec2_tag" "spot" {
  count = var.desired_size

  resource_id = data.aws_instances.spot.ids[count.index]
  key         = "Name"
  value       = "${var.eks_name}-spot"

  depends_on = [
    aws_eks_node_group.spot
  ]
}
