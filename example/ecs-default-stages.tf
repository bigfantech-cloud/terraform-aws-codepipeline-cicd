# ECS deployment
# Creates Pipeline stages & actions defined in the module

provider "aws" {
  region = "us-east-1"
}

module "cicd-backend" {
  source  = "bigfantech-cloud/codepipeline-cicd/aws"
  version = "a.b.c" # find latest version from https://registry.terraform.io/modules/bigfantech-cloud/codepipeline-cicd/aws/latest

  project_name = "abc"
  environment  = "dev"

  #---
  #CODEBUILD
  #---

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
  codestar_connection_arn = "arn::"
  aws_chatbot_slack_arn   = "arn::"
  vcs_repository          = "bigfantech/sample-backend"
  vcs_branch              = "main"
  deploy_provider         = "ECS"

  deploy_config = {
    ClusterName = "abc-cluster"
    ServiceName = "abc-service"
  }
}
