//iam role for ec2 to pass pictures to S3
resource "aws_iam_role" "EC2-CSYE6225" {
  name = "EC2-CSYE6225-Webapp"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Action" : "sts:AssumeRole"
        "Effect" : "Allow"
        "Sid" : ""
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    name = "EC2-CSYE6225-Webapp-${var.profile}"
  }
}

# iam policy for ec2 role to access s3 for webapp
resource "aws_iam_policy" "webapp_s3_policy" {
  name        = "WebAppS3-Policy"
  description = "Permissions for the S3 bucket to create secure policies."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:PutObjectAcl"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.s3_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.s3_bucket.bucket}/*"
          # "${aws_s3_bucket.s3_bucket.arn}",
          # "${aws_s3_bucket.s3_bucket.arn}/*"
        ]
      }
    ]
  })
}


# iam attachment for ec2 to pass pictures to S3
resource "aws_iam_role_policy_attachment" "attachRoletoEc2" {
  role       = aws_iam_role.EC2-CSYE6225.name
  policy_arn = aws_iam_policy.webapp_s3_policy.arn
}

# create a profile for Webapp to S3
resource "aws_iam_instance_profile" "ec2Profile" {
  name = "ec2Profile"
  role = aws_iam_role.EC2-CSYE6225.name
}
# attach CloudWatch policy to role 
resource "aws_iam_role_policy_attachment" "EC2CloudWatchAttachment" {
  role       = aws_iam_role.EC2-CSYE6225.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy" "load_balancer_autoscaling_policy" {
  name = "load_balancer_autoscaling_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:*",
          "elasticloadbalancing:*",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "asg_policy_attachment" {
  policy_arn = aws_iam_policy.load_balancer_autoscaling_policy.arn
  role       = aws_iam_role.EC2-CSYE6225.name
}

resource "aws_iam_policy" "dynamo_db_policy" {
  name   = "dynamo_db_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:DescribeTable"
        ]
        Resource = "${aws_dynamodb_table.csye6225.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamo_policy_attachment" {
  policy_arn = aws_iam_policy.dynamo_db_policy.arn
  role       = aws_iam_role.EC2-CSYE6225.name
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:*",
          "sns:*",
          "logs:*",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ],
        Effect = "Allow",
        Resource = "*"
      },
    ]
  })
}

# IAM policy for allow web application role to use kms keys
resource "aws_iam_policy" "webapp_kms_policy" {
  name        = "WebApp-KMS-Policy"
  description = "Permissions for the KMS to create secure policies."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:RevokeGrant",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:ListGrants",
          "secretsmanager: GetSecretValue"
        ],
        "Effect" : "Allow",
        "Resource" : [
          aws_kms_key.ebs.arn,
          aws_kms_key.rds.arn,
          aws_kms_key.s3_bucket_kms.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  policy_arn = aws_iam_policy.webapp_kms_policy.arn
  role       = aws_iam_role.EC2-CSYE6225.name
}

# IAM policy for allow web application role to use kms keys
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "WebApp-Secrets-Manager-Policy"
  description = "Permissions for the KMS to create secure policies."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ],
        "Effect" : "Allow",
        "Resource" : [
          aws_secretsmanager_secret.db_secret.arn,
          aws_secretsmanager_secret.email_credentials.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  role       = aws_iam_role.EC2-CSYE6225.name
}


