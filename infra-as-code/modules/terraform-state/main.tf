resource "aws_s3_bucket" "backend" {
  bucket = "${var.s3_bucket}"

  tags = {
    Name        = "${var.s3_bucket_name}"
    Environment = "${var.env}"
  }
  force_destroy = true

}

resource "aws_s3_bucket_acl" "backend" {
  bucket = aws_s3_bucket.backend.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  bucket = aws_s3_bucket.backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.bucket_sse_algorithm
    }
  }
}

resource "aws_dynamodb_table" "terraform" {
  name           = "${var.dynamodb_table}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "local_file" "backend_file" {
  filename = "backend.auto.tfvars"
  content = <<-EOT
    env                  = "${var.env}"
    s3_bucket            = "${var.s3_bucket}"
    s3_bucket_name       = "${var.s3_bucket_name}"
    dynamodb_table       = "${var.dynamodb_table}"
    bucket_sse_algorithm = "${var.bucket_sse_algorithm}"
  EOT
}