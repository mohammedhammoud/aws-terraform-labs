terraform {
  backend "s3" {
    bucket       = "455394301478-terraform-state-s3"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
