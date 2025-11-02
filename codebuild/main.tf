variable "codebuild_role" {
  description = "ARN of the CodeBuild IAM role"
  type        = string
}

variable "ecr_repository" {
  description = "Name of the ECR repository"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

resource "aws_codebuild_project" "app_build" {
  name          = "${var.project_name}-build"
  service_role  = var.codebuild_role

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repository
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}