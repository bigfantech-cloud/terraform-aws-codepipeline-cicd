locals {
  codepipeline_arn = var.stages == null ? aws_codepipeline.default[0].arn : aws_codepipeline.custom[0].arn
}

resource "aws_codepipeline" "default" {
  count = var.stages == null ? 1 : 0

  name     = module.this.id
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.vcs_repository
        BranchName       = var.vcs_branch
        DetectChanges    = var.auto_detect_vcs_changes
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.default.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = var.deploy_provider
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = var.deploy_config
      run_order     = 1
    }

    dynamic "action" {
      for_each = var.cloudfront_id_for_invalidation != null ? ["true"] : []

      content {
        name            = "CloudFront_Invalidation"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = ["source_output"]
        version         = "1"

        configuration = {
          ProjectName = aws_codebuild_project.cloudfront_invalidation[0].name
        }
        run_order = 2
      }
    }
  }

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}"
    }
  )
}

#------
# DYNAMIC STAGES
#------

resource "aws_codepipeline" "custom" {
  count = var.stages != null ? 1 : 0

  name     = module.this.id
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline.bucket
  }

  dynamic "stage" {
    for_each = [for s in var.stages : {
      name    = s.stage_name
      actions = s.actions
    }]
    # var.stages == null ? local.default_stages : {}
    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions

        content {
          name             = action.value.action_name
          category         = action.value.category
          owner            = action.value.owner
          provider         = action.value.provider
          version          = action.value.version
          input_artifacts  = lookup(action.value, "input_artifacts", null)
          output_artifacts = lookup(action.value, "output_artifacts", null)

          configuration = lookup(action.value, "configuration", null)
          run_order     = lookup(action.value, "run_order", null)
        }
      }
    }
  }

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}"
    }
  )
}
