variable "project_name" {
  type        = string
  description = "Project name for naming/tagging"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID in which to create the ALB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to attach the ALB to (usually public subnets)"
}

variable "alb_ingress_cidr" {
  type        = list(string)
  description = "CIDR blocks allowed to access the ALB"
}