terraform {
  backend "s3" {
    bucket       = "455394301478-terraform-state-s3"
    key          = "aws-terraform-labs/bootstrap/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
