resource "aws_codebuild_project" "default" {
  name         = module.this.id
  description  = "${module.this.id} project"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  environment {
    compute_type                = var.codebuild_environment_config["compute_type"]
    image                       = var.codebuild_environment_config["image"]
    type                        = var.codebuild_environment_config["type"]
    image_pull_credentials_type = var.codebuild_environment_config["image_pull_credentials_type"]
    privileged_mode             = var.codebuild_environment_config["privileged_mode"]

    environment_variable {
      name  = "project_name"
      value = module.this.project_name
    }
      
    environment_variable {
      name  = "environment"
      value = module.this.environment
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      status      = var.enable_codebuild_cloudwatch_logs ? "ENABLED" : "DISABLED"
      group_name  = aws_cloudwatch_log_group.codebuild[0].name
      stream_name = "build"
    }

    dynamic "s3_logs" {
      for_each = var.enable_codebuild_s3_logs ? ["true"] : []

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
  count = var.enable_codebuild_cloudwatch_logs ? 1 : 0
  
  name              = "/codebuild/${module.this.id}"
  retention_in_days = var.codebuild_cloudwatch_logs_retention_in_days

  tags = module.this.tags
}

#---
# CLOUDFRONT INVALIDATION
#---
  
resource "aws_codebuild_project" "cloudfront_invalidation" {
  count = var.create_cloudfront_invalidation && var.cloudfront_id_for_invalidation != null ? 1 : 0

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
    compute_type                = var.codebuild_environment_config["compute_type"]
    image                       = var.codebuild_environment_config["image"]
    type                        = var.codebuild_environment_config["type"]
    image_pull_credentials_type = var.codebuild_environment_config["image_pull_credentials_type"]
    privileged_mode             = var.codebuild_environment_config["privileged_mode"]
  }

  logs_config {
    cloudwatch_logs {
      status      = var.codebuild_cloudwatch_logs ? "ENABLED" : "DISABLED"
      group_name  = aws_cloudwatch_log_group.codebuild[0].name
      stream_name = "cloudfront-invalidation"
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
      Name = "${module.this.id}-cloudfront-invalidation"
    }
  )
}


