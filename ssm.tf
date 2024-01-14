resource "aws_kms_key" "ANP-ML-API" {
  description         = "ANP-MLDEV-API"
  enable_key_rotation = true
}

resource "aws_kms_alias" "ANP-ML-API-ALIAS" {
  name          = "alias/ANP/SSM-MLDEV"
  target_key_id = aws_kms_key.ANP-ML-API.id
}

resource "aws_ssm_parameter" "ANP-ML-API-SNOWFLAKE_PASSWORD" {
  name       = "/anp/snowflake-MLDEV"
  type       = "SecureString"
  value      = lookup(local.snowflakepassword, var.ANP-ML-API-ENV)
  key_id     = aws_kms_key.ANP-ML-API.key_id
  depends_on = [aws_kms_key.ANP-ML-API]
}

resource "aws_ssm_parameter" "ANP-ML-API-SSL-CERT" {
  name       = "/anp/sslcert-MLDEV"
  type       = "SecureString"
  value      = lookup(local.sslcert, var.ANP-ML-API-ENV)
  key_id     = aws_kms_key.ANP-ML-API.key_id
  depends_on = [aws_kms_key.ANP-ML-API]
}

resource "aws_ssm_parameter" "ANP-ML-API-SSL-KEY" {
  name       = "/anp/sslkey-MLDEV"
  type       = "SecureString"
  value      = lookup(local.sslkey, var.ANP-ML-API-ENV)
  key_id     = aws_kms_key.ANP-ML-API.key_id
  depends_on = [aws_kms_key.ANP-ML-API]
}