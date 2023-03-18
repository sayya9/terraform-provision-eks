variable "eks_name" {
  type    = string
  default = ""
}

variable "eks_vpc_cidr" {
  type    = string
  default = ""
}

variable "eks_public_subnets" {
  type    = map
  default = {}
}
