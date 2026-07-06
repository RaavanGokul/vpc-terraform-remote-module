variable "name" {
  description = "name of the VPC"
  type        = string
  default     = "gk-eks-vpc"
}

variable "region_name" {
  type    = string
  default = ""

}
variable "vpc_cidrs" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = ""
}

variable "enable_dns_host" {
  description = "boolean flag to enable/diable the DNS hosts in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "boolean flag to enable/diable the DNS support in the VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the VPC"
  type        = map(string)
  default     = {}
}

variable "create_public_subnet" {
  description = "boolean flag to enable/disable the public subnet creation"
  type        = bool
  default     = true
}

variable "public_subnet_cidrs" {
  description = "value"
  type        = list(string)
  default     = []
}

variable "public_subnet_azs" {
  description = "A list of availability zones for public subnets"
  type        = list(string)
  default     = []
}

variable "create_private_subnet" {
  type        = bool
  default     = true
  description = "boolean flag to enable/disable the public subnet creation"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = []
}

variable "private_subnet_azs" {
  description = "A list of availability zones for private subnets"
  type        = list(string)
  default     = []
}
variable "create_nat" {
  description = "A boolean flag to enable/disable the creating the NAT"
  type        = bool
  default     = true
}

variable "public_subnet_tag" {
  description = "tags for public subnets"
  type        = map(string)
  default     = {}
}
variable "private_subnet_tag" {
  description = "tags for private subnets"
  type        = map(string)
  default     = {}
}
