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
  # statement {
  #   actions = ["s3:*", ]
  #   resources = [
  #     "*"
  #   ]
  # }
  statement {
    actions = ["s3:*", ]
    resources = [
      "${aws_s3_bucket.APA-ML-Mlflow.arn}/*",
      aws_s3_bucket.APA-ML-Mlflow.arn
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
  # statement {
  #   actions = ["s3:*", ]
  #   resources = [
  #     "*"
  #   ]
  # }
  statement {
    actions = ["s3:*", ]
    resources = [
      "${aws_s3_bucket.APA-ML-Mlflow.arn}/*",
      aws_s3_bucket.APA-ML-Mlflow.arn
    ]
  }
}


resource "aws_cloudwatch_log_group" "ANP-ML-BE-MLflow" {
  name              = "/ecs/ANP-ML-BE-Mlflow"
  retention_in_days = 7
}


resource "aws_route53_record" "ANP-ML-BE-Mlflow" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dns_mlflow
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
  load_balancer_type               = "application"
  subnets                          = data.aws_subnet_ids.subnets.ids
  security_groups                  = [aws_security_group.Anp-mlflow-LB.id]
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
}

resource "aws_lb_target_group" "ANP-ML-BE-Mlflow" {
  name                 = "ANP-ML-BE-Mlflow"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = data.aws_vpc.main.id
  deregistration_delay = 300
}

resource "aws_lb_listener" "ANP-ML-BE-Mlflow" {
  load_balancer_arn = aws_lb.ANP-ML-BE-Mlflow.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  depends_on = [
    aws_lb.ANP-ML-BE-Mlflow, aws_lb_target_group.ANP-ML-BE-Mlflow
  ]
}

resource "aws_lb_listener" "ANP-ML-BE-Mlflow-https" {
  load_balancer_arn = aws_lb.ANP-ML-BE-Mlflow.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = "arn:aws:acm:eu-west-1:698178790353:certificate/16face40-6462-445b-b697-87bd2ac3c85f"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ANP-ML-BE-Mlflow.arn
  }
}

resource "aws_security_group" "Anp-mlflow-LB" {
  name        = "Anp-mlflow-LB"
  description = "Allow inbound traffic to mlflow LB"
  vpc_id      = data.aws_vpc.main.id
  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}