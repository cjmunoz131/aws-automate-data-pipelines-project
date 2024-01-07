data "aws_caller_identity" "current" {}


resource "aws_kms_key_policy" "kms_key_access" {
  key_id = var.kms_key_id
  policy = data.aws_iam_policy_document.kms_key_access.json
}

data "aws_iam_policy_document" "kms_key_access" {

  statement {
    # https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html
    sid    = "Enable Cloudwatch access to KMS Key"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.cross_target_accounts_roles

    content {
      sid       = "AllowDSServicePrincipalSSE-${statement.value.account}"
      effect    = "Allow"
      resources = ["*"]

      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*",
        "kms:GetPublicKey"
      ]

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${statement.value.account}:role/${statement.value.role_name}"]
        # identifiers = ["arn:aws:iam::697682206292:role/*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.cross_target_accounts_roles

    content {
      sid       = "AllowDSSPResourceAttachments-${statement.value.account}"
      effect    = "Allow"
      resources = ["*"]

      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ]

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values = [
          "true"
        ]
      }

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${statement.value.account}:role/${statement.value.role_name}"]
        # identifiers = ["arn:aws:iam::697682206292:role/*"]
      }
    }
  }
}