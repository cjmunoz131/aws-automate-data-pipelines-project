data "aws_caller_identity" "current" {}
### Create S3 bucket to receive data
resource "aws_s3_bucket" "S3Bucket" {

  bucket_prefix = format("%s-%s", var.bucket_datalake_name, "${data.aws_caller_identity.current.account_id}")
  force_destroy = true

  tags = {
    Name  = format("%s-%s", var.bucket_datalake_name, "${data.aws_caller_identity.current.account_id}"),
    rtype = "storage"
  }
}

resource "aws_s3_bucket_policy" "S3Bucket" {
  bucket = aws_s3_bucket.S3Bucket.id
  policy = data.aws_iam_policy_document.S3Bucket.json
}

data "aws_iam_policy_document" "S3Bucket" {
  statement {
    sid    = "Allow HTTPS only"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3*"
    ]
    resources = [
      "${aws_s3_bucket.S3Bucket.arn}",
      "${aws_s3_bucket.S3Bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }

  statement {
    sid    = "Allow TLS 1.2 and above"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3*"
    ]
    resources = [
      "${aws_s3_bucket.S3Bucket.arn}",
      "${aws_s3_bucket.S3Bucket.arn}/*"
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.S3Bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.S3Bucket]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "S3Bucket" {
  bucket = aws_s3_bucket.S3Bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "S3Bucket" {
  bucket = aws_s3_bucket.S3Bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}



resource "aws_s3_bucket_public_access_block" "S3Bucket" {
  bucket                  = aws_s3_bucket.S3Bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}