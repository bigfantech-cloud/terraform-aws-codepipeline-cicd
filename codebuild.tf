resource "aws_codebuild_project" "default" {
  name         = module.this.id
  description  = "${module.this.id} project"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${var.buildspec_path}")
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "environment"
      value = module.this.environment
    }

    environment_variable {
      name  = "project_name"
      value = module.this.project_name
    }

  }

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {

    cloudwatch_logs {
      status      = var.codebuild_cloudwatch_logs ? "ENABLED" : "DISABLED"
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "build"
    }

    dynamic "s3_logs" {
      for_each = var.codebuild_s3_logs ? ["true"] : []

      content {
        status   = "ENABLED"
        location = aws_s3_bucket.codebuild[0].id
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.codebuild_inside_vpc ? ["true"] : []
    content {
      vpc_id             = var.vpc_id
      subnets            = var.subnet_id
      security_group_ids = ["${aws_security_group.codebuild_sg[0].id}"]
    }
  }

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}"
    }
  )
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/codebuild/${module.this.id}"
  retention_in_days = 90

  tags = module.this.tags
}

#---
# CLOUDFRONT INVALIDATION
#---
resource "aws_codebuild_project" "cloudfront_invalidation" {
  count = var.create_cloudfront_invalidation ? 1 : 0

  name         = "${module.this.id}-cf-invalidation-project"
  description  = "${module.this.id} CloudFront invalidation project"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type      = "NO_SOURCE"
    buildspec = <<-EOT
    version: 0.2

    phases:
      build:
        commands:
          - echo Creating CloudFront Invalidation...
          - AWS_PAGER=""
          - aws cloudfront create-invalidation --distribution-id ${var.cloudfront_id_for_invalidation} --paths "/*"
EOT
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {

    cloudwatch_logs {
      status      = var.codebuild_cloudwatch_logs ? "ENABLED" : "DISABLED"
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "cf-invalidation"
    }
  }

  dynamic "vpc_config" {
    for_each = var.codebuild_inside_vpc ? ["true"] : []
    content {
      vpc_id             = var.vpc_id
      subnets            = var.subnet_id
      security_group_ids = ["${aws_security_group.codebuild_sg[0].id}"]
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
    name = null
  }

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}-cf-invalidation-project"
    }
  )
}


