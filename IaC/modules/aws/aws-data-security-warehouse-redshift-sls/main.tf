data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "redshift-serverless-security-group" {

  name        = format("%s-%s-%s", "redshift-sls", terraform.workspace, "sg")
  description = "redshift-serverless-security-group"

  vpc_id = var.vpc_id

  ingress {
    description = "Redshift port"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // update this to secure the connection to Redshift
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allows connection to vpc endpoint s3"
  }

  tags = {
    Name = format("%s-%s-%s", "sg", terraform.workspace, "redshift-sls")
  }
}

resource "aws_iam_role" "redshift-serverless-role" {
  name = format("%s-%s-%s", "iap", terraform.workspace, "redshift-sls")

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = format("%s-%s-%s", "iap", terraform.workspace, "redshift-sls")
  }
}



resource "aws_iam_role_policy" "RedshiftSLSRolePolicy" {
  name = format("%s-%s-%s", "irp", terraform.workspace, "redshift-sls")
  role = aws_iam_role.redshift-serverless-role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartition",
          "glue:UpdateDatabase",
          "glue:UpdateTable",
          "glue:UpdatePartition",
          "glue:BatchCreatePartition",
          "glue:CreatePartition",
          "glue:CreateTable",
          "glue:GetSecurityConfiguration",
          "glue:GetConnection"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:glue:${var.Region}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${var.Region}:${data.aws_caller_identity.current.account_id}:database/${var.glue_database_name}",
          "arn:aws:glue:${var.Region}:${data.aws_caller_identity.current.account_id}:table/${var.glue_database_name}/${var.glue_table_prefix}*"
        ]
      },
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
        ]
        Effect = "Allow"
        Resource = [
          "${var.s3_bucket_arn}",
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*",
          "kms:Describe*",
          "kms:GetPublicKey",
          "kms:ListAliases",
        ]
        Effect = "Allow"
        Resource = [
          "${var.kms_key_arn}"
        ]
      },
      {
        Action = [
          "logs:AssociateKmsKey",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${var.Region}:${data.aws_caller_identity.current.account_id}:log-group:*"
        ]
      }
    ]
  })
}

# data "aws_iam_policy" "redshift-full-access-policy" {
#   name = "AmazonRedshiftAllCommandsFullAccess"
# }

# # Attach the policy to the Redshift role
# resource "aws_iam_role_policy_attachment" "attach-s3" {
#   role       = aws_iam_role.redshift-serverless-role.name
#   policy_arn = data.aws_iam_policy.redshift-full-access-policy.arn
# }