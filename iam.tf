# IAM Role for Terraform with minimal permissions
resource "aws_iam_role" "terraform_role" {
  name = "terraform_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect   = "Allow"
        Sid      = ""
      }
    ]
  })
}

# Attach the policy for accessing S3 and DynamoDB to the role
resource "aws_iam_policy" "terraform_policy" {
  name        = "terraform_policy"
  description = "Policy for Terraform access to S3 and DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::home-tech-terraform-state/*"
        ]
        Effect   = "Allow"
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:DescribeTable"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:123456789012:table/terraform-locks"
        Effect   = "Allow"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "terraform_role_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}
