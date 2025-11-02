terraform {
  backend "s3" {
    #bucket       = ""   # Your bucket
    key          = "cicd-pipeline/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = false
  }
}