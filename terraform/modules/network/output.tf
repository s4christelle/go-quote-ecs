output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}