variable "project_name" {
  type        = string
  description = "Name of the project for tagging"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks for the public subnets"
}
variable "availability_zones" {
  type        = list(string)
  description = "List of availability zone names"
}