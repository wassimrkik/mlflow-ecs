variable "ANP-ML-API-ENV" {
  type = string
}

variable "ANP-ML-API-TASK-CPU" {
  type = number
}

variable "ANP-ML-API-TASK-MEM" {
  type = number
}

variable "ANP-ML-API-TASK-PORT" {
  type = number
}

variable "ANP-ML-API-CAPACITY" {
  type = number
}
variable "awsregion" {
  type = string
}

variable "ANP-ML-API-CONTAINER-TAG" {
  type = string
}

variable "ANP-ML-SOLVER" {
  type = string
}

variable "APA-ML-BE-SNOWFLAKE-ACCOUNT" {
  type = string
}

variable "APA-ML-BE-SNOWFLAKE-ROLE" {
  type = string
}

variable "APA-ML-BE-SNOWFLAKE-USER" {
  type = string
}

variable "APA-ML-BE-SNOWFLAKE-WH" {
  type = string
}

variable "APA-ML-BE-SNOWFLAKE-DB" {
  type = string
}
variable "APA-ML-BE-S3-BUCKET" {
  type = string
}

variable "snowflakepassword_dev" {
  type      = string
  sensitive = true
}

variable "snowflakepassword_uat" {
  type      = string
  sensitive = true
}

variable "snowflakepassword_prod" {
  type      = string
  sensitive = true
}

variable "sslkey_dev" {
  type      = string
  sensitive = true
}
variable "sslkey_uat" {
  type      = string
  sensitive = true
}
variable "sslkey_prod" {
  type      = string
  sensitive = true
}

variable "sslcert_dev" {
  type      = string
  sensitive = true
}
variable "sslcert_uat" {
  type      = string
  sensitive = true
}
variable "sslcert_prod" {
  type      = string
  sensitive = true
}