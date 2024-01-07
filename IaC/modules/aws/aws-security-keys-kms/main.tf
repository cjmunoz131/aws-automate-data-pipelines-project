### Create KMS key
resource "aws_kms_key" "KMSKey" {
  deletion_window_in_days = 7
  description             = "Encryption key"
  enable_key_rotation     = true

  tags = {
    Name  = "${var.key_name}-kms-key"
    rtype = "security"
  }
}

resource "aws_kms_alias" "KMSKeyAlias" {
  name          = "alias/${var.key_name}-kms-key"
  target_key_id = aws_kms_key.KMSKey.key_id
}