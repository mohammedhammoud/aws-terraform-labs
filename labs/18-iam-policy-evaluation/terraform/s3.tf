resource "aws_s3_bucket" "lab" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${var.project_name}-lab"
  force_destroy = true
}

resource "aws_s3_object" "read_me" {
  bucket  = aws_s3_bucket.lab.id
  key     = "allowed/read-me.txt"
  content = "This object should be readable."
}

resource "aws_s3_object" "secret" {
  bucket  = aws_s3_bucket.lab.id
  key     = "private/secret.txt"
  content = "This object should not be readable."
}
