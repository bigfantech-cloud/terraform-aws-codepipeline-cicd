variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = list(string)
  default     = []
}

variable "cb_log_bucket_force_destroy" {
  description = "Delete all objects from the bucket so that the bucket can be destroyed without error. Default = false"
  type        = bool
  default     = false
}


variable "cp_artifact_bucket_force_destroy" {
  description = "Delete all objects from CodePipeline Artifact bucket so that the bucket can be destroyed without error. Default = false"
  type        = bool
  default     = false
}

variable "aws_chatbot_slack_arn" {
  description = <<EOF
  AWS ChatBot Slack client configuration ARN.
  AWS ChatBot Slack Client Configuration need to be done from console.
  EOF
  type        = string
  default     = null
}

#-----
#CODEBUILD
#-----

variable "codebuild_inside_vpc" {
  description = "Enable CodeBuild inside VPC, true or false. Default = false"
  type        = bool
  default     = false
}

variable "buildspec_path" {
  description = "Buildspec file path."
  type        = string
  default     = null
}

variable "codebuild_cloudwatch_logs" {
  description = "Enable CloudWathach log for CodeBuild. Defaul = true"
  default     = true
}

variable "codebuild_s3_logs" {
  description = "Save CodeBuild logs in S3 bucket. Defaul = false"
  default     = false
}

variable "additional_codebuild_iam_permisssions" {
  description = "List of additional permissions to attach to CodeBuild IAM policy. Ex: [\"ecs:*\", \"cloudwatch:*\"] "
  type        = list(any)
  default     = []
}

#-----
#CODEPIPELINE
#-----

variable "additional_codepipeline_iam_permisssions" {
  description = "List of additional permissions to attach to CodePipeline IAM policy. Ex: [\"ecs:*\", \"cloudwatch:*\"] "
  type        = list(any)
  default     = []
}

variable "codestar_connection_arn" {
  description = "CodeStar connection ARN for CodePipeline."
  type        = string
  default     = null
}

variable "deploy_provider" {
  description = "CodePipeline Deployment provider. Ex: ECS, S3,.."
  type        = string
  default     = null
}

variable "deploy_config" {
  description = <<EOF
  "Map of CodePipeline Deployment configuration"
   ex (ECS):
  {
    ClusterName = test_cluster
    ServiceName = test_service
  }
  ex (S3):
  {
   BucketName = "test_bucket"
   Extract = "true"
   ObjectKey = "project1"
 }
  EOF
  type        = map(any)
  default     = null
}

variable "github_repository" {
  description = "GitHub repository name. Ex: studiographen/tf-module"
  type        = string
  default     = null
}

variable "github_branch" {
  description = "GitHub repository branch to use as source"
  type        = string
  default     = null
}

variable "create_cloudfront_invalidation" {
  description = "Whether to create invalidation. Default = false"
  type        = bool
  default     = false
}

variable "cloudfront_id_for_invalidation" {
  description = "Provide CloudFront distribution ID to create invalidation. A post deployment action will be added to CodePipeline. Default = null"
  type        = string
  default     = null
}

variable "detect_changes" {
  description = "Whether to detect changes automatically when code is merged in branch"
  type        = string
  default     = "true"
}

variable "stages" {
  description = <<-EOT
  List of Map with stage_name, and actions in list configs.
  
  Example: [
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
            FullRepositoryId = "bigfantech/fuze-admin"
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
        }
      ]
    }
  ]
  EOT
  default     = null
}