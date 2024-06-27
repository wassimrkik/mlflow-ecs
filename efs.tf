#----------------------------------------
# EFS
#----------------------------------------
resource "aws_efs_file_system" "efs_volume" {
  performance_mode                = "generalPurpose"
  encrypted                       = true
  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = 100
  creation_token                  = "mlflow-efs-volume"
  tags = {
    Name = "ANP-Mlflow-Backend-Store"
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs_volume.id
  backup_policy {
    status = "ENABLED"
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
# resource "aws_security_group_rule" "ecs_loopback_rule" {
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   self              = true
#   description       = "Loopback"
#   security_group_id = aws_security_group.ANP-ML-BE-Mlflow.id
# }

