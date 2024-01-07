output "s3_bucket_name" {
  description = "S3 bucket name (datalake)"
  value       = aws_s3_bucket.S3Bucket.bucket
}

output "s3_bucket_arn" {
  description = "arn from S3 bucket"
  value       = aws_s3_bucket.S3Bucket.arn
}

output "s3_bucket_id" {
  description = "id of S3 bucket name"
  value       = aws_s3_bucket.S3Bucket.id
}