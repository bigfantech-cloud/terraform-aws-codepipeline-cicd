# ECS deployment
# Creates Pipeline with custom defined stages & actions

module "cicd-backend" {
  source  = "bigfantech-cloud/codepipeline-cicd/aws"
  version = "a.b.c" # find latest version from https://registry.terraform.io/modules/bigfantech-cloud/codepipeline-cicd/aws/latest

  project_name = "abc"
  environment  = "dev"

  #---
  #CODEBUILD
  #---

  codebuild_inside_vpc = true
  vpc_id               = "<vpc_id>"
  subnet_id            = ["<subnet_ids>"]
  buildspec = templatefile("./buildspec/ecs.tpl", {
    "_project_name_"       = "abc"
    "_environment_"        = "dev"
    "_application_name_"   = "server"
    "_ecr_repository_url_" = "<ecr-url>"
    }
  )

  #---
  #CODEPIPELINE
  #---

  stages = [
    {
      stage_name = "Source"
      actions = [
        {
          action_name      = "Source"
          category         = "Source"
          owner            = "AWS"
          provider         = "CodeStarSourceConnection"
          version          = "1"
          output_artifacts = ["source_output"]

          configuration = {
            ConnectionArn    = "arn:aws:codestar-connections:::"
            FullRepositoryId = "bigfantech-cloud/application1"
            BranchName       = "dev"
          }
        }
      ]
    },

    {
      stage_name = "Build"
      actions = [
        {
          action_name      = "Build"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          version          = "1"

          configuration = {
            ProjectName = "abc-build-project"
          }
        }
      ]
    },

    {
      stage_name = "Deploy"
      actions = [
        {
          action_name     = "Deploy"
          category        = "Deploy"
          owner           = "AWS"
          provider        = "ECS"
          input_artifacts = ["build_output"]
          version         = "1"

          deploy_config = {
            ClusterName = "abc-cluster"
            ServiceName = "abc-service"
          }
          run_order = 1
        }
      ]
    }
  ]
}
