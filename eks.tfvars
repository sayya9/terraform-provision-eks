eks_name = "devops-demo-eks"
eks_vpc_cidr = "10.111.0.0/16"
eks_public_subnets = {
  public-subnet-1 = {
    az = "us-west-2a"
    cidr = "10.111.0.0/19"
  }
  public-subnet-2 = {
    az = "us-west-2b"
    cidr = "10.111.32.0/19"
  }
  public-subnet-3 = {
    az = "us-west-2c"
    cidr = "10.111.64.0/19"
  }
}
eks_private_subnets = {
  private-subnet-1 = {
    az = "us-west-2a"
    cidr = "10.111.96.0/19"
  }
  private-subnet-2 = {
    az = "us-west-2b"
    cidr = "10.111.128.0/19"
  }
  private-subnet-3 = {
    az = "us-west-2c"
    cidr = "10.111.160.0/19"
  }
}
