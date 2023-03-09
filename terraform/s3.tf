resource "aws_s3_bucket" "s3_kops" {
  bucket = var.s3_bucker_name
  tags = {
    Name = "hallsholicker-kops-${var.study_name}"
  }
}

resource "aws_s3_bucket_acl" "s3_kops_acl" {
  bucket = aws_s3_bucket.s3_kops.id
  acl    = "private"
}
