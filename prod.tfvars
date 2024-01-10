ANP-ML-API-ENV              = "prod"
awsregion                   = "eu-west-1"
ANP-ML-API-CAPACITY         = "5"
ANP-ML-API-TASK-CPU         = "1024"
ANP-ML-API-TASK-MEM         = "2048"
ANP-ML-API-TASK-PORT        = "443"
ANP-ML-SOLVER               = "datalab-gurobi.p015068701664.aws-emea.sanofi.com:61000"
APA-ML-BE-SNOWFLAKE-ACCOUNT = "sanofi-emea_chc"
APA-ML-BE-SNOWFLAKE-USER    = "APA_PROD_TRANSFORM"
APA-ML-BE-SNOWFLAKE-ROLE    = "APA_PROD_TRANSFORM_PROC"
APA-ML-BE-SNOWFLAKE-WH      = "APA_PROD_WH_TRANSFORM"
APA-ML-BE-SNOWFLAKE-DB      = "apa_prod"
APA-ML-BE-S3-BUCKET         = "sanofi-chc-emea-anp-prod"
ANP-ML-API-CONTAINER-TAG    = "latest"
ANP-ML-API-S3-BUCKET        = "sanofi-chc-emea-anp-prod"
SNOWFLAKE_WAREHOUSE         = "APA_PROD_WH_TRANSFORM"
DATABRICKS_SECRET_ID        = "arn:aws:secretsmanager:eu-west-1:317782366132:secret:apa/databricks-mlflow-service-principal-CgxdGg"
SNOWFLAKE_USER              = "APA_PROD_TRANSFORM"
SNOWFLAKE_DB_APA            = "apa_prod"
DATABRICKS_HOST             = "https://sanofi-datalab-PRODelopment-amer.cloud.databricks.com/"
APA-ML-BE-API-TOKEN-ARN     = "arn:aws:secretsmanager:eu-west-1:317782366132:secret:apa/ml-api-token-58npSv"