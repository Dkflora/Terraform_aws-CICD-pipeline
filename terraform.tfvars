aws_region      = "us-east-1"
project_name    = "dev-app"
container_image = "devops:latest"
desired_count   = 1

# GitHub configuration
github_owner       = "Dkflora"            # Your github username
github_repo        = "terraform_aws-cicd" # Your github repo
github_branch      = "main"
github_oauth_token = "" # Set up a github Oauth Token and replace the value here
