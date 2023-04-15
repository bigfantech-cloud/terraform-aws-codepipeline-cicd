#-----
#CODEBUILD
#-----

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
  policy = data.aws_iam_policy_document.codebuild_permissions.json
}

data "aws_iam_policy_document" "codebuild_permissions" {
  statement {
    effect = "Allow"

    actions = compact(concat([
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "kms:*",
      "ssm:*",
      #"ssm:GetParameters",
      "ecr:*",
      #"ecr:InitiateLayerUpload",
      #"ecr:UploadLayerPart",
      #"ecr:CompleteLayerUpload",
      #"ecr:BatchCheckLayerAvailability",
      #"ecr:PutImage",
      "codepipeline:*",
      "iam:PassRole",
      "ecs:*",
      #"ecs:DescribeTaskDefinition",
      "cloudfront:CreateInvalidation",
      "codedeploy:*",
      "cloudwatch:*",
      "sns:*",
      "s3:*",
      "ec2:*"
      # "ec2:DescribeVpcs",
      # "ec2:DeleteNetworkInterface",
      # "ec2:DescribeSecurityGroups",
      # "ec2:DescribeSubnets",
      # "ec2:DescribeNetworkInterfaces",
      # "ec2:CreateNetworkInterface",
      # "ec2:DescribeDhcpOptions",
    ], var.additional_codebuild_iam_permisssions))

    resources = [
      "*"
    ]
  }
}

#-----
#CODEPIPELINE
#-----

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
  policy = data.aws_iam_policy_document.codepipeline_permissions.json
}

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
      # "codebuild:BatchGetBuilds",
      # "codebuild:StartBuild",
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



