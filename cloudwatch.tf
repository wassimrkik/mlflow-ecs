resource "aws_cloudwatch_log_group" "ANP-ML-API" {
  name              = "/ecs/Anp-APA-MLDEV-API"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs_events" {
  name = "/aws/events/${var.ID-SERVICE}"
}

# AWS EventBridge rule
resource "aws_cloudwatch_event_rule" "ecs_events" {
  name        = "${var.ID-SERVICE}-ecs-events"
  description = "Capture all ECS events"

  event_pattern = jsonencode({
    "source" : ["aws.ecs"],
    "detail" : {
      "clusterArn" : [aws_ecs_cluster.ANP-ML-API.arn]
    }
  })
}

# AWS EventBridge target
resource "aws_cloudwatch_event_target" "logs" {
  rule      = aws_cloudwatch_event_rule.ecs_events.name
  target_id = "send-to-cloudwatch"
  arn       = aws_cloudwatch_log_group.ecs_events.arn
}

# CloudWatch logs error filter metric
resource "aws_cloudwatch_log_metric_filter" "ecs_errors" {
  name           = "ECS Errors"
  pattern        = "{ $.detail.group = \"*\" && $.detail.stopCode = \"TaskFailedToStart\" }"
  log_group_name = aws_cloudwatch_log_group.ecs_events.name

  metric_transformation {
    name      = "ECSErrors"
    namespace = "ECSEvents"
    value     = "1"
    unit      = "Count"
    dimensions = {
      group = "$.detail.group"
    }
  }
}

# AWS CloudWatch metric alarm
resource "aws_cloudwatch_metric_alarm" "service_crashes" {
  alarm_name          = "ECS service is stopped with error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ECSErrors"
  namespace           = "ECSEvents"
  period              = "300"
  statistic           = "SampleCount"
  threshold           = "1"
  alarm_description   = "crashes occured"
  alarm_actions       = [aws_sns_topic.monitoring.arn]
  ok_actions          = [aws_sns_topic.monitoring.arn]
  treat_missing_data  = "breaching"

  dimensions = {
    group = "service:our-ecs-service"
  }
}

# AWS SNS topic
resource "aws_sns_topic" "monitoring" {
  name = "monitoring-mldev-api"
  kms_master_key_id = "alias/aws/sns"
  tags = {
    environment = var.ANP-ML-API-ENV
  }
}

resource "aws_sns_topic_policy" "SNS-UI" {
  arn    = aws_sns_topic.monitoring.arn
  policy = data.aws_iam_policy_document.sns_delivery.json
}
data "aws_iam_policy_document" "sns_delivery" {
  policy_id = "__default_policy_ID"
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        local.aws_account_id,
      ]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.monitoring.arn,
    ]
    sid = "__default_statement_ID"
  }
  statement {
    actions = [
      "SNS:Publish"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.monitoring.arn,
    ]
    sid = "AllowPublishThroughSSLOnly"
  }
}


resource "aws_sns_topic_subscription" "SNS-API" {
  for_each  = toset(var.EMAIL-NOTIFICATION)
  topic_arn = aws_sns_topic.monitoring.arn
  protocol  = "email"
  endpoint  = each.value
}