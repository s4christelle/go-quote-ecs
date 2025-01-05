variable "project_name" {
  type        = string
  description = "Project name for naming/tagging"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ECS cluster will be created"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for ECS tasks"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID to optionally restrict inbound traffic"
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group"
}

variable "cpu_scale_out_threshold" {
  type        = number
  description = "CPU threshold for scaling out ECS tasks"
}

variable "cpu_scale_in_threshold" {
  type        = number
  description = "CPU threshold for scaling in ECS tasks"
}

variable "min_capacity" {
  type        = number
  description = "Minimum ECS tasks"
}

variable "max_capacity" {
  type        = number
  description = "Maximum ECS tasks"
}