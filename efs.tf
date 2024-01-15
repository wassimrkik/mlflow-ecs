#----------------------------------------
# EFS
#----------------------------------------
resource "aws_efs_file_system" "efs_volume" {
  performance_mode = "generalPurpose"

  creation_token = "grafana-efs-volume"
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

}

resource "aws_efs_mount_target" "ecs_temp_space_az0" {
  file_system_id  = aws_efs_file_system.efs_volume.id
  subnet_id       = tolist(data.aws_subnet_ids.subnets.ids)[0]
  security_groups = ["${aws_security_group.ANP-ML-BE-Mlflow.id}"]
}

resource "aws_efs_mount_target" "ecs_temp_space_az1" {
  file_system_id  = aws_efs_file_system.efs_volume.id
  subnet_id       = tolist(data.aws_subnet_ids.subnets.ids)[1]
  security_groups = ["${aws_security_group.ANP-ML-BE-Mlflow.id}"]
}

#----------------------------------------
# ECS security-group loop back rule to connect to EFS Volume
#----------------------------------------
resource "aws_security_group_rule" "ecs_loopback_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  description       = "Loopback"
  security_group_id = aws_security_group.ANP-ML-BE-Mlflow.id
}

resource "aws_security_group_rule" "ecs_loopback_rule2" {
  type              = "ingress"
  from_port         = 0
  to_port           = 2049
  protocol          = "-1"
  self              = true
  description       = "Loopback"
  security_group_id = aws_security_group.ANP-ML-BE-Mlflow.id
}