

resource "aws_ecs_task_definition" "ANP-ML-BE-Mlflow" {
  family                   = "ANP-ML-BE-Mlflow"
  execution_role_arn       = module.IAM_role_ANP-Mlflow-Execution.role_arn
  task_role_arn            = module.IAM_role_ANP-Mlflow-Task.role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.APA-ML-BE-MLFLOW-TASK-CPU
  memory                   = var.APA-ML-BE-MLFLOW-TASK-MEM
  container_definitions = jsonencode([
    {
      name       = "ANP-ML-BE-Mlflow"
      image      = "${local.aws_account_id}.dkr.ecr.${local.aws_region_name}.amazonaws.com/anp/mlflow:${var.ANP-ML-API-CONTAINER-TAG}"
      entryPoint = ["sh", "-c"]
      command    = ["mlflow server --host 0.0.0.0 --port 80 --backend-store-uri /efs/ --default-artifact-root s3://sanofi-chc-${lookup(local.region_mapping, local.aws_region_name)}-anp-mlflow-${var.ANP-ML-API-ENV} --serve-artifacts"]
      environment = [
        {
          "name" : "ENV",
          "value" : var.ANP-ML-API-ENV
        },
        {
          "name" : "AWS_DEFAULT_REGION",
          "value" : local.aws_region_name
      }]
      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : local.aws_region_name,
          "awslogs-group" : "/ecs/ANP-ML-BE-Mlflow",
          "awslogs-stream-prefix" : "ecs"
      } }
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
          hostPort      = 80
        }
      ]
      "mountPoints" : [
        {
          "sourceVolume" : "efs_temp",
          "containerPath" : "/efs",
          "readOnly" : false
        }
      ]
    }
  ])
  volume {
    name = "efs_temp"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs_volume.id
      root_directory = "/"
    }
  }
}

resource "aws_ecs_service" "ANP-ML-BE-Mlflow" {
  name            = "ANP-ML-BE-Mlflow"
  cluster         = aws_ecs_cluster.ANP-ML-API.id
  task_definition = aws_ecs_task_definition.ANP-ML-BE-Mlflow.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnet_ids.subnets.ids
    security_groups  = [data.aws_security_group.internet_access.id, aws_security_group.ANP-ML-BE-Mlflow.id, data.aws_security_group.default.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ANP-ML-BE-Mlflow.arn
    container_name   = "ANP-ML-BE-Mlflow"
    container_port   = var.APA-ML-BE-MLFLOW-PORT
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
  depends_on = [aws_ecs_task_definition.ANP-ML-BE-Mlflow, aws_ecs_cluster.ANP-ML-API]
}



resource "aws_security_group" "ANP-ML-BE-Mlflow" {
  name        = "ANP-ML-BE-Mlflow"
  description = "Allow inbound traffic to ANP-ML-BE-Mlflow service"
  vpc_id      = data.aws_vpc.main.id
  ingress {
    from_port   = var.APA-ML-BE-MLFLOW-PORT
    to_port     = var.APA-ML-BE-MLFLOW-PORT
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
    #cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_s3_bucket" "APA-ML-Mlflow" {
  bucket = "sanofi-chc-${lookup(local.region_mapping, local.aws_region_name)}-anp-mlflow-${var.ANP-ML-API-ENV}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  force_destroy = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    id      = "Expire non-current objects"
    enabled = true

    noncurrent_version_expiration {
      days = 45
    }
    expiration {
      expired_object_delete_marker = true
    }
    abort_incomplete_multipart_upload_days = 7
  }
}

module "IAM_role_ANP-Mlflow-Execution" {
  source      = "./module"
  role_name   = "ANP-Mlflow-Execution"
  service     = "ecs-tasks"
  policy_json = data.aws_iam_policy_document.ANP-Mlflow-Execution.json
}

data "aws_iam_policy_document" "ANP-Mlflow-Execution" {
  statement {
    actions = ["s3:*", ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = ["s3:*", ]
    resources = [
      "arn:aws:s3:::sanofi-chc-emea-anp-mlflow-dev/*",
      "arn:aws:s3:::sanofi-chc-emea-anp-mlflow-dev"
    ]
  }
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
}

module "IAM_role_ANP-Mlflow-Task" {
  source      = "./module"
  role_name   = "ANP-Mlflow-Task"
  service     = "ecs-tasks"
  policy_json = data.aws_iam_policy_document.ANP-Mlflow-Task.json
}

data "aws_iam_policy_document" "ANP-Mlflow-Task" {
  statement {
    actions = ["s3:*", ]
    resources = [
      "*"
    ]
  }
}


resource "aws_cloudwatch_log_group" "ANP-ML-BE-MLflow" {
  name              = "/ecs/ANP-ML-BE-Mlflow"
  retention_in_days = 7
}


resource "aws_route53_record" "ANP-ML-BE-Mlflow" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "anp-mlflow"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.ANP-ML-BE-Mlflow.dns_name]
  depends_on = [
    aws_lb.ANP-ML-BE-Mlflow
  ]
}


resource "aws_lb" "ANP-ML-BE-Mlflow" {
  name                             = "ANP-ML-BE-Mlflow"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = data.aws_subnet_ids.subnets.ids
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = true
}

resource "aws_lb_target_group" "ANP-ML-BE-Mlflow" {
  name                 = "ANP-ML-BE-Mlflow"
  port                 = 80
  protocol             = "TCP"
  target_type          = "ip"
  vpc_id               = data.aws_vpc.main.id
  deregistration_delay = 300
  health_check {
    interval = 30
    protocol = "TCP"
  }
  stickiness {
    enabled = true
    type    = "source_ip"
  }
}

resource "aws_lb_listener" "ANP-ML-BE-Mlflow" {
  load_balancer_arn = aws_lb.ANP-ML-BE-Mlflow.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ANP-ML-BE-Mlflow.arn
  }
  depends_on = [
    aws_lb.ANP-ML-BE-Mlflow, aws_lb_target_group.ANP-ML-BE-Mlflow
  ]
}