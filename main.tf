terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# ECS + ALB Infrastructure
module "alb_ecs" {
  source              = "./alb_ecs"
  aws_region          = var.aws_region
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  container_name      = var.container_name
  container_image     = var.container_image
  container_port      = var.container_port
  cpu                 = var.cpu
  memory              = var.memory
  desired_count       = var.desired_count
  min_capacity        = var.min_capacity
  max_capacity        = var.max_capacity
  cpu_target_value    = var.cpu_target_value
  memory_target_value = var.memory_target_value
  log_retention_days  = var.log_retention_days
}

# IAM Roles
module "iam" {
  source = "./iam"
}

# CodeBuild
module "codebuild" {
  source         = "./codebuild"
  codebuild_role = module.iam.codebuild_role_arn
  ecr_repository = module.alb_ecs.ecr_repository_name
  aws_region     = var.aws_region
  aws_account_id = data.aws_caller_identity.current.account_id
  project_name   = var.project_name
}

# CodeDeploy
module "codedeploy" {
  source                  = "./codedeploy"
  codedeploy_role         = module.iam.codedeploy_role_arn
  ecs_cluster_name        = module.alb_ecs.ecs_cluster_name
  ecs_service_name        = module.alb_ecs.ecs_service_name
  listener_arn            = module.alb_ecs.alb_listener_arn
  blue_target_group_name  = module.alb_ecs.blue_target_group_name
  green_target_group_name = module.alb_ecs.green_target_group_name
  project_name            = var.project_name
}

# CodePipeline
module "codepipeline" {
  source                 = "./codepipeline"
  codebuild_project_name = module.codebuild.project_name
  codedeploy_app_name    = module.codedeploy.app_name
  codedeploy_group_name  = module.codedeploy.group_name
  codepipeline_role_arn  = module.iam.codepipeline_role_arn
  ecr_repository_name    = module.alb_ecs.ecr_repository_name
  project_name           = var.project_name
  github_owner           = var.github_owner
  github_repo            = var.github_repo
  github_branch          = var.github_branch
  github_oauth_token     = var.github_oauth_token
}