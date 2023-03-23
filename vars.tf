variable "region" {
  type    = string
  default = ""
}

variable "eks_name" {
  type    = string
  default = ""
}

variable "eks_vpc_cidr" {
  type    = string
  default = ""
}

variable "desired_size" {
  type    = number
  default = 3
}

variable "max_size" {
  type    = number
  default = 5
}

variable "min_size" {
  type    = number
  default = 1
}

variable "eks_public_subnets" {
  type    = map
  default = {}
}

variable "eks_private_subnets" {
  type    = map
  default = {}
}
