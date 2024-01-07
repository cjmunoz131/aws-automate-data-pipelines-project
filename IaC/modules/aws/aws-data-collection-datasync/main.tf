resource "aws_iam_role" "datasync-s3-source-role" {
  name = var.datasync_source_location_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "datasync.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "datasync-s3-target-role" {
  name = var.datasync_target_location_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "datasync.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "datasync-service-source-policy" {
  name = "datasync-policy-${var.datasync_collector_name}"
  role = aws_iam_role.datasync-s3-source-role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:GetObject",
          "s3:Describe*",
          "s3:GetObjectVersion",
          "s3:AbortMultipartUpload",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging"
        ]
        Effect = "Allow"
        Resource = [
          "${var.s3_datasource_arn}",
          "${var.s3_datasource_arn}/*"
        ]
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:Encrypt*",
          "kms:DescribeKey",
          "kms:GetPublicKey"
        ]
        Effect = "Allow"
        Resource = [
          "${var.kms_key_source_arn}"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy" "datasync-service-target-policy" {
  name = "datasync-policy-${var.datasync_collector_name}"
  role = aws_iam_role.datasync-s3-target-role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:Describe*",
          "s3:PutObjectTagging",
          "s3:GetObjectTagging",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:GetObject"
        ]
        Effect = "Allow"
        Resource = [
          "${var.s3_datalake_arn}",
          "${var.s3_datalake_arn}/*"
        ]
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:Encrypt*",
          "kms:DescribeKey",
          "kms:GetPublicKey"
        ]
        Effect = "Allow"
        Resource = [
          "${var.kms_key_arn}"
        ]
      }
    ]
  })
}

resource "aws_datasync_location_s3" "source" {
  # depends_on = [aws_datasync_agent.datasync_agent]

  s3_bucket_arn = var.s3_datasource_arn
  subdirectory  = var.datasync_source_location_s3_subdirectory

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync-s3-source-role.arn
  }

  tags = {
    Name = "datasync-agent-source-location-s3"
  }
}

resource "aws_datasync_location_s3" "target" {
  # depends_on    = [aws_datasync_agent.datasync_agent]
  s3_bucket_arn = var.s3_datalake_arn
  subdirectory  = var.datasync_target_location_s3_subdirectory

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync-s3-target-role.arn
  }

  tags = {
    Name = "datasync-agent-target-location-s3"
  }
}

# Instance Role for the ec2 which host the datasync agent
resource "aws_iam_role" "datasync-instance-role" {
  name = "datasync-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "datasync-instance-role"
  }
}

resource "aws_iam_role_policy" "datasync-instance-policy" {
  name = "datasync-policy-${var.datasync_collector_name}"
  role = aws_iam_role.datasync-instance-role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "datasync:*"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_datasync_task.s3_cross_account_ds_task.arn}"
        ]
      },
      {
        Action = [
          "ec2:*"
        ]
        Effect = "Allow"
        Resource = [
          "*"
        ]
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:Encrypt*"
        ]
        Effect = "Allow"
        Resource = [
          "${var.kms_key_arn}"
        ]
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:Encrypt*"
        ]
        Effect = "Allow"
        Resource = [
          "${var.kms_key_source_arn}"
        ]
      },
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:GetObject",
          "s3:Describe*",
          "s3:GetObjectVersion",
          "s3:AbortMultipartUpload"
        ]
        Effect = "Allow"
        Resource = [
          "${var.s3_datasource_arn}"
        ]
      },
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:Describe*",
          "s3:PutObjectTagging",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload"
        ]
        Effect = "Allow"
        Resource = [
          "${var.s3_datalake_arn}"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "cloudwatch_log_group" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]
    resources = ["${aws_cloudwatch_log_group.datasync_task_loggroup.arn}"]
    principals {
      identifiers = ["datasync.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_group" "datasync_task_loggroup" {
  name              = "ds_task_${var.datasync_collector_name}-lg"
  retention_in_days = 7

  tags = {
    Name = "ds_task_${var.datasync_collector_name}-lg"
  }
}

resource "aws_datasync_task" "s3_cross_account_ds_task" {
  name                     = "datasync-task-${var.datasync_collector_name}"
  source_location_arn      = aws_datasync_location_s3.source.arn
  destination_location_arn = aws_datasync_location_s3.target.arn
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.datasync_task_loggroup.arn

  options {
    bytes_per_second       = -1
    verify_mode            = var.datasync_task_options["verify_mode"]
    posix_permissions      = var.datasync_task_options["posix_permissions"]
    preserve_deleted_files = var.datasync_task_options["preserve_deleted_files"]
    uid                    = var.datasync_task_options["uid"]
    gid                    = var.datasync_task_options["gid"]
    atime                  = var.datasync_task_options["atime"]
    mtime                  = var.datasync_task_options["mtime"]
    object_tags            = "NONE"
    log_level              = "TRANSFER"
  }

  tags = {
    Name = "datasync-task-${var.datasync_collector_name}"
  }
}