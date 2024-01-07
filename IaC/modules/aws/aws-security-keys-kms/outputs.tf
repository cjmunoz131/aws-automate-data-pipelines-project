output "kms_key_arn" {
  value = aws_kms_key.KMSKey.arn
}

output "kms_key_id" {
  value = aws_kms_key.KMSKey.id
}