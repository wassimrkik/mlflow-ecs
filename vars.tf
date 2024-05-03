variable "ANP-ML-API-ENV" {
  type = string
}

variable "ID-SERVICE" {
  type = string
}
variable "EMAIL-NOTIFICATION" {
  type = list(any)
}
variable "APA-ML-BE-MLFLOW-PORT" {

}

variable "APA-ML-BE-MLFLOW-TASK-CPU" {

}

variable "APA-ML-BE-MLFLOW-TASK-MEM" {

}
variable "ANP-ML-API-S3-BUCKET" {
  type = string
}

variable "SNOWFLAKE_WAREHOUSE" {
  type = string

}

variable "SNOWFLAKE_USER" {
  type = string
}

variable "SNOWFLAKE_DB_APA" {
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

variable "snowflakepassword_qa" {
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
variable "sslkey_qa" {
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

variable "APA-ML-BE-API-TOKEN-ARN" {
  type = string
}
variable "sslcert_dev" {
  type      = string
  sensitive = true
}

variable "sslcert_qa" {
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
variable "dns_name" {
  type = string
}
variable "dns_mlflow" {
  type = string
}

variable "MLFLOW_CERT_ARN" {

}
variable "SNOWFLAKE_SCHEMA" {

}

variable "APA-ML-BE-SNOWFLAKE-ACCOUNT" {

}