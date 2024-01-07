output "bucket_s3_arn" {
  value = aws_s3_bucket.S3Bucket.arn
}

output "bucket_name" {
  value = aws_s3_bucket.S3Bucket.id
}