data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "mwaa_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["airflow.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["airflow-env.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mwaa" {
  statement {
    effect = "Allow"
    actions = [
      "airflow:PublishMetrics",
      "airflow:CreateWebLoginToken" // validar si es necesario
    ]
    resources = [
      "arn:${data.aws_partition.current.id}:airflow:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:environment/${var.name_mwaa_env}"
    ]
  }
  #   "s3:GetAccountPublicAccessBlock"
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      var.source_bucket_arn,
      "${var.source_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "arn:${data.aws_partition.current.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.name_mwaa_env}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "cloudwatch:PutMetricData",
      "batch:DescribeJobs",
      #   "eks:*",
      "batch:ListJobs"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = [
      "arn:${data.aws_partition.current.id}:sqs:${data.aws_region.current.name}:*:airflow-celery-*"
    ]
  }

  dynamic "statement" {
    for_each = var.kms_key != null ? [] : [1]
    content {
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey*",
        "kms:Encrypt"
      ]
      not_resources = [
        "arn:${data.aws_partition.current.id}:kms:*:${data.aws_caller_identity.current.account_id}:key/*"
      ]
      condition {
        test     = "StringLike"
        variable = "kms:ViaService"

        values = [
          "sqs.${data.aws_region.current.name}.amazonaws.com",
          "s3.${data.aws_region.current.name}.amazonaws.com"
        ]
      }
    }
  }

  dynamic "statement" {
    for_each = var.kms_key != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey*",
        "kms:Encrypt"
      ]
      resources = [
        var.kms_key
      ]
      condition {
        test     = "StringLike"
        variable = "kms:ViaService"

        values = [
          "sqs.${data.aws_region.current.name}.amazonaws.com",
          "s3.${data.aws_region.current.name}.amazonaws.com"
        ]
      }
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "batch:*",
    ]
    resources = [
      "arn:${data.aws_partition.current.id}:batch:*:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:*"
    ]
    resources = [
      "arn:${data.aws_partition.current.id}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:*"
    ]
    resources = ["arn:${data.aws_partition.current.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:*"]
    resources = ["arn:${data.aws_partition.current.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"]
  }
}

resource "aws_iam_role" "mwaa_role" {
  name               = var.iam_role_name
  description        = "MWAA IAM Role"
  assume_role_policy = data.aws_iam_policy_document.mwaa_assume.json
  #   force_detach_policies = var.force_detach_policies
  path = var.iam_role_path
}

resource "aws_iam_role_policy" "mwaa" {
  name_prefix = "mwaa-executor"
  role        = aws_iam_role.mwaa_role.id
  policy      = data.aws_iam_policy_document.mwaa.json
}

resource "aws_iam_role_policy_attachment" "mwaa" {
  for_each   = var.iam_role_additional_policies
  policy_arn = each.value
  role       = aws_iam_role.mwaa_role.id
}

resource "aws_security_group" "mwaa_sg" {
  name        = "mwaa-sg"
  description = "Security group for MWAA environment"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "mwaa_sg"
  }
}

resource "aws_security_group_rule" "mwaa_sg_inbound" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = aws_security_group.mwaa_sg.id
  security_group_id        = aws_security_group.mwaa_sg.id
  description              = "Amazon MWAA inbound access"
}

# resource "aws_security_group_rule" "mwaa_sg_inbound_vpn" {
#   count = var.create_security_group && length(var.source_cidr) > 0 ? 1 : 0

#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = var.source_cidr
#   security_group_id = aws_security_group.mwaa_sg.id
#   description       = "VPN Access for Airflow UI"
# }

resource "aws_security_group_rule" "mwaa_sg_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mwaa_sg.id
  description       = "Amazon MWAA outbound access"
}