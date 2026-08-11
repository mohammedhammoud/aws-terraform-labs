resource "aws_s3_bucket" "test" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${var.project_name}"
  force_destroy = true
}

resource "aws_s3_object" "test" {
  bucket  = aws_s3_bucket.test.id
  key     = "test.txt"
  content = "hello from s3"
}
