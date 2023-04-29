# Purpose:

To setup CodeBuild, CodePipeline CICD.

## Variable Inputs:

REQUIRED:

```
- project_name               (example: project name)
- environment                (example: dev/prod)
- buildspec                  Buildspec file. Use file() or use EOT to pass buildspec
- vcs_repository             VCS repository name. (example: bigfantech-cloud/app1)
- vcs_branch                 VCS repository branch to use as source
- deploy_provider            (ex: ECS, S3)
- vpc_id                     (ex: module.network.vpc_id)
- subnet_id                  (ex: module.network.subnet_ids)
- codestar_connection_arn    CodeStar connection ARN for CodePipeline.
- aws_chatbot_slack_arn:
    AWS ChatBot Slack client configuration ARN.
    AWS ChatBot Slack Client Configuration need to be done from console.

deploy_config exapmple for deploy proiver (ECS)
- deploy_config = {
    ClusterName = "<ecs-cluster-name>"
    ServiceName = "<ecs-service-name>"
  }

deploy_config example for deploy proiver (S3)
- deploy_config = {
    BucketName = "<bucket-name>"
    Extract    = "true"
  }
```

OPTIONAL:

```
- create_cloudfront_invalidation:
    Whether to create invalidation. Default = false.

- cloudfront_id_for_invalidation:
    Provide CloudFront distribution ID to create invalidation. A post-deployment action will be added to CodePipeline
    to create CloudFront invalidation. This is used when CloudFront + S3 deployment is done, to clear cache in edge locations.
    default     = null

- stages
    CodePipeline stages config. List of Map with **stage_name**, and **actions** as list.
    For actions attributes, ref. [CodePipeline action](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline#action)

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

- codebuild_inside_vpc:             Enable CodeBuild inside VPC, true or false. Default = false

- codebuild_cloudwatch_logs:        Enable CloudWathach log for CodeBuild, true or false. Default = true

- codebuild_s3_logs:                Save CodeBuild logs in S3 bucket. Defaul = false"

- cb_log_bucket_force_destroy:
    Delete all objects from CodeBuild log bucket so that the bucket can be destroyed without error. `true` or `false`
    Default = false.

- cp_artifact_bucket_force_destroy:
    Delete all objects from CodePipeline Artifact bucket so that the bucket can be destroyed without error.`true` or `false`
    Default = false.

- additional_codebuild_iam_permisssions:    List of additional permissions to attach to CodeBuild IAM policy.
                                            example: ["ecs:*", "cloudwatch:*"]

- additional_codepipeline_iam_permisssions: List of additional permissions to attach to CodePipeline IAM policy.
                                            example: ["ecs:*", "cloudwatch:*"]

- auto_detect_vcs_changes:
    Whether to detect changes automatically when there is change in VCS branch. Default = "true"
```

## Major resources created:

- CodeBuild Projects
- CodePipeline
- S3 buckets
- IAM policy CodeBuild role
- IAM policy CodePipeline role

# Steps to create the resources

1. Call the module from your tf code.
2. Specify variable inputs.

Example:

Default stages:

```
provider "aws" {
  region = "us-east-1"

}

module "cicd-backend" {
  source        = "bigfantech-cloud/codepipeline-cicd/aws"
  version       = "1.0.0"
  project_name  = "abc"
  environment   = "dev"

  #---
  #CODEBUILD
  #---

  codebuild_inside_vpc            = true
  vpc_id                          = module.network.vpc_id
  subnet_id                       = module.network.subnet_ids
  buildspec                       = file("./buildspec.yml")
  codebuild_cloudwatch_logs       = true
  create_cloudfront_invalidation  = true
  cloudfront_id_for_invalidation  = "abcd12345"

  #---
  #CODEPIPELINE
  #---
  codestar_connection_arn = "arn::"
  aws_chatbot_slack_arn   = "arn::"
  vcs_repository          = "bigfantech/sample-backend"
  ccs_branch              = "main"
  deploy_provider         = "ECS"

  deploy_config = {
    ClusterName = "abc-cluster"
    ServiceName = "abc-service"
  }
}

```

Custom stages:

```
module "cicd-backend" {
  source        = "bigfantech-cloud/codepipeline-cicd/aws"
  version       = "1.0.0"
  project_name  = "abc"
  environment   = "dev"

  #---
  #CODEBUILD
  #---

  codebuild_inside_vpc      = true
  vpc_id                    = module.network.vpc_id
  subnet_id                 = module.network.subnet_ids
  buildspec                 = file("./buildspec.yml")
  codebuild_cloudwatch_logs = true

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
          run_order = 1
        },
        {
          action_name     = "CloudFront_Invalidation"
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          input_artifacts = ["source_output"]
          version         = "1"

          configuration = {
            ProjectName = "abc-build"
          }
          run_order = 2
        }
      ]
    }
  ]

}
```

3. Apply: From terminal run following commands.

```
terraform init
```

```
terraform plan
```

```
terraform apply
```

!! You have successfully setup CICD components as per your specification !!

---

## OUTPUTS

```
codebuild_security_group_id
  Security Group attached to CodeBuild project.

codebuild_project_name:
  CodeBuild Project Name.

codepipeline_arn:
  CodePipeline ARN.
```
