resource "aws_s3_bucket" "test" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${var.project_name}-bucket"
  force_destroy = true
}

resource "aws_s3_object" "test" {
  bucket  = aws_s3_bucket.test.id
  key     = "tmp/test.txt"
  content = "This is a test file."
}
