module "IAM_role_ANP-ML-API-execution" {
  source      = "./module"
  role_name   = "ANP-APA-ML-API-Execution"
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
    ]
  }
}

module "IAM_role_ANP-ML-API-Task" {
  source      = "./module"
  role_name   = "ANP-ML-API-Task"
  service     = "ecs-tasks"
  policy_json = data.aws_iam_policy_document.ANP-ML-API-Task.json
}

data "aws_iam_policy_document" "ANP-ML-API-Task" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetBucketLocation"
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
    resources = ["arn:aws:secretsmanager:eu-west-1:698178790353:secret:apa/ml-api-token-xE6p0n"]
  }
  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["*"]
  }
}

module "IAM_role_ecs_ANP-ML-API-Scale" {
  source      = "./module"
  role_name   = "ANP-ML-API-Scale"
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