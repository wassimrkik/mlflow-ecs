resource "aws_cloudwatch_log_group" "ANP-ML-API" {
  name              = "/ecs/Anp-APA-MLDEV-API"
  retention_in_days = 7
}