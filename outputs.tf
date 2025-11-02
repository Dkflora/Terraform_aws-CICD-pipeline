output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.alb_ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.alb_ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.alb_ecs.ecs_service_name
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb_ecs.alb_dns_name
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = module.codedeploy.app_name
}

output "codedeploy_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = module.codedeploy.group_name
}

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = module.codepipeline.pipeline_name
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = module.codebuild.project_name
}