module "IAM_role_ANP-ML-API-execution" {
  source      = "./module"
  role_name   = "ANP-APA-ML-API-MLDEV-Execution"
  service     = "ecs-tasks"
  policy_json = data.aws_iam_policy_document.ANP-ML-API-execution.json
}

data "aws_iam_policy_document" "ANP-ML-API-execution" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.ANP-ML-API.arn
    ]
  }
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      aws_ssm_parameter.ANP-ML-API-SNOWFLAKE_PASSWORD.arn,
      aws_ssm_parameter.ANP-ML-API-SSL-CERT.arn,
      aws_ssm_parameter.ANP-ML-API-SSL-KEY.arn
    ]
  }
}

module "IAM_role_ANP-ML-API-Task" {
  source      = "./module"
  role_name   = "ANP-ML-API-MLDEV-Task"
  service     = "ecs-tasks"
  policy_json = data.aws_iam_policy_document.ANP-ML-API-Task.json
}

data "aws_iam_policy_document" "ANP-ML-API-Task" {
  statement {
    actions = [
    "s3:*"]
    resources = ["arn:aws:s3:::${var.APA-ML-BE-S3-BUCKET}"]
  }
  statement {
    actions = [
    "efs:*"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.ANP-ML-API.arn,
    ]
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [var.DATABRICKS_SECRET_ID, var.APA-ML-BE-API-TOKEN-ARN]
  }
  statement {
    actions = [
      "s3:*"
    ]
    resources = ["arn:aws:s3:::${var.APA-ML-BE-S3-BUCKET}/*", "arn:aws:s3:::${var.APA-ML-BE-S3-BUCKET}/", "arn:aws:s3:::${var.APA-ML-BE-S3-BUCKET}/apa/*"]
  }
}

module "IAM_role_ecs_ANP-ML-API-Scale" {
  source      = "./module"
  role_name   = "ANP-ML-API-MLDEV-Scale"
  service     = "application-autoscaling"
  policy_json = data.aws_iam_policy_document.ANP-ML-API-Scale.json
}

data "aws_iam_policy_document" "ANP-ML-API-Scale" {
  statement {
    actions = [
      "ecs:DescribeServices",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "ecs:UpdateService"
    ]
    resources = [
      aws_ecs_service.ANP-ML-API.id
    ]
  }
}