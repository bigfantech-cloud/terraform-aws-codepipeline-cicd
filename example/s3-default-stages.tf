# S3 deployment
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
  create_cloudfront_invalidation = true
  cloudfront_id_for_invalidation = "abcd12345"
  buildspec = templatefile("./buildspec/s3.tpl", {
    "_environment_"      = "dev"
    "_application_name_" = "server"
    }
  )

  #---
  #CODEPIPELINE
  #---
  codestar_connection_arn = "arn::"
  aws_chatbot_slack_arn   = "arn::"
  vcs_repository          = "bigfantech/sample-backend"
  vcs_branch              = "main"
  deploy_provider         = "S3"

  deploy_config = {
    BucketName = "abc-bucket"
    Extract    = true
  }
}
