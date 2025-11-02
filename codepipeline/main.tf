variable "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  type        = string
}

variable "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  type        = string
}

variable "codedeploy_group_name" {
  description = "Name of the CodeDeploy deployment group"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "github_owner" {
  description = "GitHub owner/username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch"
  type        = string
}

variable "github_oauth_token" {
  description = "GitHub OAuth token"
  type        = string
  sensitive   = true
}

# S3 Bucket for Artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "codepipeline-${var.project_name}-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# CodePipeline using GitHub Version 1 (OAuth - works immediately)
resource "aws_codepipeline" "app_pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_oauth_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ApplicationName     = var.codedeploy_app_name
        DeploymentGroupName = var.codedeploy_group_name
      }
    }
  }

  depends_on = [aws_s3_bucket_ownership_controls.artifacts]
}