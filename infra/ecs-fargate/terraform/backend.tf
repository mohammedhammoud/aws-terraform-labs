terraform {
  backend "s3" {
    bucket       = "392938852724-terraform-state-s3"
    key          = "aws-terraform-labs/ecs-fargate/dev/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
