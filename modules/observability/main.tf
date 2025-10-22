# CloudWatch Log Groups for EKS observability
resource "aws_cloudwatch_log_group" "eks_observability" {
  name              = "/aws/eks/${var.project_name}/observability"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-eks-observability"
  }
}

# EFS for persistent storage (can be used by monitoring pods)
resource "aws_efs_file_system" "observability" {
  creation_token = "${var.project_name}-observability-efs"
  encrypted      = true

  tags = {
    Name = "${var.project_name}-observability-efs"
  }
}

resource "aws_efs_mount_target" "observability" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.observability.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

# Security Group for EFS
resource "aws_security_group" "efs" {
  name_prefix = "${var.project_name}-efs-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-efs-sg"
  }
}

data "aws_region" "current" {}
