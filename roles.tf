resource "aws_iam_role" "ec2_secrets_manager_role" {
  name = "EC2SecretsManagerAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "secrets_manager_access" {
  name = "SecretsManagerAccessPolicy"
  role = aws_iam_role.ec2_secrets_manager_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue",
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_secrets_manager_profile" {
  name = "EC2SecretsManagerProfile"
  role = aws_iam_role.ec2_secrets_manager_role.name
}
