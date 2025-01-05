# -----------------------------------------------------------------------------
# MODULE: Network
# -----------------------------------------------------------------------------


data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source = "./modules/network"

  project_name     = var.project_name
  vpc_cidr_block   = var.vpc_cidr_block
  public_subnets   = var.public_subnets
  availability_zones = data.aws_availability_zones.available.names

}

# -----------------------------------------------------------------------------
# MODULE: ALB
# -----------------------------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  project_name        = var.project_name
  vpc_id              = module.network.vpc_id
  subnet_ids          = module.network.public_subnet_ids
  alb_ingress_cidr    = var.alb_ingress_cidr_blocks
}

# -----------------------------------------------------------------------------
# MODULE: ECS
# -----------------------------------------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn

  cpu_scale_out_threshold = var.cpu_scale_out_threshold
  cpu_scale_in_threshold  = var.cpu_scale_in_threshold
  min_capacity            = var.min_capacity
  max_capacity            = var.max_capacity
}