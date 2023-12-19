resource "aws_ecs_cluster" "ANP-ML-API" {
  name = "ANP-ML-API"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "ANP-ML-API" {
  family                   = "ANP-ML-API"
  task_role_arn            = module.IAM_role_ANP-ML-API-Task.role_arn
  execution_role_arn       = module.IAM_role_ANP-ML-API-execution.role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ANP-ML-API-TASK-CPU
  memory                   = var.ANP-ML-API-TASK-MEM
  container_definitions = jsonencode([
    {
      name       = "ANP-ML-API"
      image      = "${local.aws_account_id}.dkr.ecr.${local.aws_region_name}.amazonaws.com/anp/ml-api:${var.ANP-ML-API-CONTAINER-TAG}"
      entryPoint = ["sh", "-c"]
      command    = ["/bin/echo -ne $SSL_KEY > /tmp/key.pem; chmod 600 /tmp/key.pem; /bin/echo -ne $SSL_CERT > /tmp/cert.pem; uvicorn api.app:app --ssl-keyfile /tmp/key.pem --ssl-certfile /tmp/cert.pem --host 0.0.0.0 --port ${var.ANP-ML-API-TASK-PORT}"]
      environment = [
        {
          "name" : "SNOWFLAKE_ACCOUNT",
          "value" : "sanofi-emea_chc"
        },
        {
          "name" : "http_proxy",
          "value" : "http://emea-aws-webproxy.service.cloud.local:3128"
        },
        {
          "name" : "no_proxy",
          "value" : "127.0.0.1,169.254.169.254,.sanofi.com,.snowflakecomputing.com,.amazonaws.com"
        },
        {
          "name" : "NO_PROXY",
          "value" : "127.0.0.1,169.254.169.254,.sanofi.com,.snowflakecomputing.com,.amazonaws.com"
        },
        {
          "name" : "COMPUTESERVER",
          "value" : "datalab-gurobi.p015068701664.aws-emea.sanofi.com:61000"
        },
        {
          "name" : "https_proxy",
          "value" : "http://emea-aws-webproxy.service.cloud.local:3128"
        },
        {
          "name" : "SNOWFLAKE_ROLE",
          "value" : "APA_DEV_TRANSFORM_PROC"
        },
        {
          "name" : "AWS_DEFAULT_REGION",
          "value" : "eu-west-1"
        },
        {
          "name" : "HTTP_PROXY",
          "value" : "http://emea-aws-webproxy.service.cloud.local:3128"
        },
        {
          "name" : "ENV",
          "value" : "dev"
        },
        {
          "name" : "S3_BUCKET_NAME_APA",
          "value" : "sanofi-chc-emea-anp-workbench-dev"
        },
        {
          "name" : "HTTPS_PROXY",
          "value" : "http://emea-aws-webproxy.service.cloud.local:3128"
        },
        {
          "name" : "SNOWFLAKE_WAREHOUSE",
          "value" : "APA_DEV_WH_TRANSFORM"
        },
        {
          "name" : "MLFLOW_TRACKING_URI",
          "value" : "datalab-apa-mlflow.p893159272749.aws-amer.sanofi.com"
        },
        {
          "name" : "SNOWFLAKE_USER",
          "value" : "APA_DEV_TRANSFORM"
        },
        {
          "name" : "SNOWFLAKE_DB_APA",
          "value" : "apa_dev"
        }
      ]
      secrets = [{
        "name" : "SNOWFLAKE_PASSWORD",
        "valueFrom" : aws_ssm_parameter.ANP-ML-API-SNOWFLAKE_PASSWORD.arn
        },
        {
          "name" : "SSL_KEY",
          "valueFrom" : aws_ssm_parameter.ANP-ML-API-SSL-KEY.arn
        },
        {
          "name" : "SSL_CERT",
          "valueFrom" : aws_ssm_parameter.ANP-ML-API-SSL-CERT.arn
        }
      ]
      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : local.aws_region_name,
          "awslogs-group" : "/ecs/Anp-APA-ML-API",
          "awslogs-stream-prefix" : "ecs"
        }
      }
      portMappings = [
        {
          containerPort = var.ANP-ML-API-TASK-PORT
          protocol      = "tcp"
          hostPort      = var.ANP-ML-API-TASK-PORT
        }
      ]
    }
    ]
  )
}
resource "aws_ecs_service" "ANP-ML-API" {
  name            = "ANP-ML-API-service"
  cluster         = aws_ecs_cluster.ANP-ML-API.id
  task_definition = aws_ecs_task_definition.ANP-ML-API.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnet_ids.subnets.ids
    security_groups  = [data.aws_security_group.internet_access.id, aws_security_group.ANP-ML-API.id, data.aws_security_group.default.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ANP-ML-API.arn
    container_name   = "ANP-ML-API"
    container_port   = var.ANP-ML-API-TASK-PORT
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
  depends_on = [aws_ecs_task_definition.ANP-ML-API, aws_ecs_cluster.ANP-ML-API]
}

resource "aws_appautoscaling_target" "ANP-ML-API" {
  max_capacity       = var.ANP-ML-API-CAPACITY
  min_capacity       = 1
  resource_id        = "service/ANP-ML-API/ANP-ML-API-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = module.IAM_role_ecs_ANP-ML-API-Scale.role_arn
  depends_on         = [aws_ecs_service.ANP-ML-API]
}

resource "aws_appautoscaling_policy" "ANP-ML-API-CPU" {
  name               = "ANP-ML-API-CPU"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ANP-ML-API.resource_id
  scalable_dimension = aws_appautoscaling_target.ANP-ML-API.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ANP-ML-API.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ANP-APA-ML-BE-Predict-MEM" {
  name               = "ANP-APA-ML-BE-Predict-MEM"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ANP-ML-API.resource_id
  scalable_dimension = aws_appautoscaling_target.ANP-ML-API.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ANP-ML-API.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 50
  }
}