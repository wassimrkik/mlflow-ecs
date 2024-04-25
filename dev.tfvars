ANP-ML-API-ENV              = "dev"
awsregion                   = "eu-west-1"
ANP-ML-API-CAPACITY         = "5"
ANP-ML-API-TASK-CPU         = "1024"
ANP-ML-API-TASK-MEM         = "2048"
ANP-ML-API-TASK-PORT        = "443"
ANP-ML-SOLVER               = "datalab-gurobi.p015068701664.aws-emea.sanofi.com:61000"
APA-ML-BE-SNOWFLAKE-ACCOUNT = "sanofi-emea_chc"
APA-ML-BE-SNOWFLAKE-USER    = "APA_DEV_TRANSFORM"
APA-ML-BE-SNOWFLAKE-ROLE    = "APA_DEV_TRANSFORM_PROC"
APA-ML-BE-SNOWFLAKE-WH      = "APA_DEV_WH_TRANSFORM"
APA-ML-BE-SNOWFLAKE-DB      = "apa_dev"
APA-ML-BE-S3-BUCKET         = "sanofi-chc-emea-anp-workbench-dev"
ANP-ML-API-CONTAINER-TAG    = "latest"
ANP-ML-API-S3-BUCKET        = "sanofi-chc-emea-anp-workbench-dev"
SNOWFLAKE_WAREHOUSE         = "APA_DEV_WH_TRANSFORM"
SNOWFLAKE_USER              = "APA_DEV_TRANSFORM"
SNOWFLAKE_DB_APA            = "apa_dev"
APA-ML-BE-API-TOKEN-ARN     = "arn:aws:secretsmanager:eu-west-1:698178790353:secret:apa/ml-api-token-xE6p0n"
APA-ML-BE-MLFLOW-TASK-CPU   = "2048"
APA-ML-BE-MLFLOW-TASK-MEM   = "4096"
APA-ML-BE-MLFLOW-PORT       = "80"
EMAIL-NOTIFICATION          = ["mohamed.wassim-ext@sanofi.com", "cyril.noirot@sanofi.com"]
ID-SERVICE                  = "API-MLDEV"
dns_name                    = "anp-api-mldev"
dns_mlflow                  = "anp-mlflow"
MLFLOW_CERT_ARN             = "arn:aws:acm:eu-west-1:698178790353:certificate/16face40-6462-445b-b697-87bd2ac3c85f"