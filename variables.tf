variable "vpc_id" {
  description = "VPC ID to run CodeBuild in"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "List of subnet IDs to run CodeBuild in"
  type        = list(string)
  default     = null
}

variable "aws_chatbot_slack_arn" {
  description = <<-EOT
    AWS ChatBot Slack client configuration ARN
    AWS ChatBot Slack Client Configuration must be done from console
  EOT
  type        = string
  default     = null
}

variable "codestar_connection_arn" {
  description = "CodeStar connection ARN for CodePipeline"
  type        = string
  default     = null
}

#-----
#CODEBUILD
#-----

variable "codebuild_environment_config" {
  description = <<-EOT
    Map of CodeBuild runner environment config containing `compute_type`, `image`, `type`, `image_pull_credentials_type`, `privileged_mode`
    Default = {
      compute_type                = "BUILD_GENERAL1_SMALL"
      image                       = "aws/codebuild/standard:6.0"
      type                        = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
      privileged_mode             = true
    }
  EOT
  type = object({
    compute_type                = string
    image                       = string
    type                        = string
    image_pull_credentials_type = string
    privileged_mode             = bool
  })
  
  default = {
      compute_type                = "BUILD_GENERAL1_SMALL"
      image                       = "aws/codebuild/standard:6.0"
      type                        = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
      privileged_mode             = true
 }
}

variable "codebuild_inside_vpc" {
  description = "Enable CodeBuild inside VPC. Default = false"
  type        = bool
  default     = false
}

variable "buildspec" {
  description = "Buildspec file. Use file() or use EOT to pass buildspec"
  type        = string
  default     = null
}

variable "enable_codebuild_cloudwatch_logs" {
  description = "Enable CloudWathach log for CodeBuild. Defaul = true"
  type        = bool
  default     = true
}

variable "codebuild_cloudwatch_logs_retention_in_days" {
  description = "Number in days to retain CodeBuild logs in CloudWatch. Defaul = 90"
  type        = number
  default     = 90
}

variable "enable_codebuild_s3_logs" {
  description = "Save CodeBuild logs in S3 bucket. Defaul = false"
  type        = bool
  default     = false
}

variable "codebuild_log_bucket_force_destroy" {
  description = "Delete all objects from the CodeBuild log bucket, so that the bucket can be destroyed without error. Default = false"
  type        = bool
  default     = false
}

variable "create_codebuild_log_bucket_lifecycle" {
  description = "Whether to create CodeBuild log bucket object lifecycle. Default = true"
  type        = bool
  default     = true
}

variable "codebuild_log_bucket_lifecycle_transition_days" {
  description = "Number in days after which objects are transistioned to Glacier. Default = 90"
  type        = number
  default     = 90
}

variable "codebuild_log_bucket_lifecycle_expiration_days" {
  description = "Number in days after which objects are deleted. Default = 180"
  type        = number
  default     = 180
}

variable "additional_codebuild_iam_permisssions" {
  description = "List of additional permissions to attach to CodeBuild IAM policy defined in this module. example: [\"ecs:*\", \"cloudwatch:*\"]"
  type        = list(any)
  default     = []
}

variable "custom_codebuild_policy_document" {
  description = <<-EOT
    Custom policy document for CodeBuild to attach instead of policy defined in this module.
    Use `aws_iam_policy_document` data block to generate JSON
  EOT
  type        = string
  default     = null
}

#-----
#CODEPIPELINE
#-----

variable "codepipeline_artifact_bucket_force_destroy" {
  description = "Delete all objects from CodePipeline Artifact bucket, so that the bucket can be destroyed without error. Default = false"
  type        = bool
  default     = false
}

variable "custom_codepipeline_policy_document" {
  description = <<-EOT
    Custom policy document for CodePipeline to attach instead of policy defined in this module.
    Use `aws_iam_policy_document` data block to generate JSON
  EOT
  type        = string
  default     = null
}

variable "additional_codepipeline_iam_permisssions" {
  description = "List of additional permissions to attach to CodePipeline IAM policy defined in this module. example: [\"ecs:*\", \"cloudwatch:*\"]"
  type        = list(any)
  default     = []
}

variable "deploy_provider" {
  description = "CodePipeline Deployment provider. example: ECS, S3,.."
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

variable "vcs_repository" {
  description = "VCS repository name. Ex: bigfantech-cloud/app1"
  type        = string
  default     = null
}

variable "vcs_branch" {
  description = "VCS repository branch to use as source"
  type        = string
  default     = null
}

variable "create_cloudfront_invalidation" {
  description = "Whether to create invalidation. A post deployment action will be added to CodePipeline. Default = false"
  type        = bool
  default     = false
}

variable "cloudfront_id_for_invalidation" {
  description = <<-EOT
    CloudFront distribution ID to create invalidation for
    This is used when CloudFront + S3 deployment is done, to clear cache in edge locations
    Default = null
  EOT
  type        = string
  default     = null
}

variable "auto_detect_vcs_changes" {
  description = "Whether to detect changes automatically when there is change in VCS branch"
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
