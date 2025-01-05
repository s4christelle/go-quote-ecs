variable "region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name for tagging and resource naming"
  default     = "go-quotes-app"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "alb_ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access the ALB"
  default     = ["0.0.0.0/0"]
}

variable "cpu_scale_out_threshold" {
  type        = number
  description = "CPU threshold (percentage) for scaling out"
  default     = 70
}


variable "cpu_scale_in_threshold" {
  type        = number
  description = "CPU threshold (percentage) for scaling in"
  default     = 30
}

variable "min_capacity" {
  type        = number
  description = "Minimum number of ECS tasks"
  default     = 2
}

variable "max_capacity" {
  type        = number
  description = "Maximum number of ECS tasks"
  default     = 5
}