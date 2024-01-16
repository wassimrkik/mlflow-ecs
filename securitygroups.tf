resource "aws_security_group" "ANP-ML-API" {
  name        = "ANP-MLDEV-API"
  description = "Allow inbound traffic to ANP-ML-API service"
  vpc_id      = data.aws_vpc.main.id
  ingress {
    from_port   = var.ANP-ML-API-TASK-PORT
    to_port     = var.ANP-ML-API-TASK-PORT
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self = true
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}