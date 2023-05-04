#-----
#CODEBUILD
#-----

data "aws_iam_policy_document" "codebuild_permissions" {
  statement {
    effect = "Allow"

    actions = compact(concat([
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "kms:*",
      "ssm:GetParameter*",
      "ssm:DescribeParameters",
      "ecr:*",
      "codepipeline:*",
      "iam:PassRole",
      "ecs:*",
      "cloudfront:CreateInvalidation",
      "codedeploy:*",
      "cloudwatch:*",
      "sns:*",
      "s3:*",
      "ec2:*"
    ], var.additional_codebuild_iam_permisssions))

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "${module.this.id}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "codebuild.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = module.this.tags
}


resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${module.this.id}-codebuild-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = var.custom_codebuild_policy_document != null ? var.custom_codebuild_policy_document : data.aws_iam_policy_document.codebuild_permissions.json
}

#-----
#CODEPIPELINE
#-----

data "aws_iam_policy_document" "codepipeline_permissions" {
  statement {
    effect = "Allow"

    actions = compact(concat([
      "kms:*",
      "ssm:*",
      "iam:PassRole",
      "ecs:*",
      "ecr:*",
      "codedeploy:*",
      "codebuild:*",
      "cloudwatch:*",
      "sns:*",
      "rds:*",
      "s3:*",
    ], var.additional_codepipeline_iam_permisssions))

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codestar-connections:UseConnection"
    ]

    resources = [
      var.codestar_connection_arn,
    ]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${module.this.id}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "codepipeline.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = module.this.tags
}


resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${module.this.id}-codepipeline-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = var.custom_codepipeline_policy_document != null ? var.custom_codepipeline_policy_document : data.aws_iam_policy_document.codepipeline_permissions.json
}



