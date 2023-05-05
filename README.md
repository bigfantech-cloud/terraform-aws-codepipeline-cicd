# BigFantech-Cloud

We automate your infrastructure.
You will have full control of your infrastructure, including Infrastructure as Code (IaC).

To hire, email: `bigfantech@yahoo.com`

# Purpose of this code

> Terraform module

To setup CodeBuild, CodePipeline CICD.

## Required Providers

| Name                | Description |
| ------------------- | ----------- |
| aws (hashicorp/aws) | >= 4.47     |

## Variables

### Required Variables

| Name                      | Description                                                                                                                                                                                                                               | Default |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `project_name`            |                                                                                                                                                                                                                                           |         |
| `environment`             |                                                                                                                                                                                                                                           |         |
| `buildspec`               | Buildspec file. Use file() or EOT to pass buildspec                                                                                                                                                                                   |         |
| `vcs_repository`          | VCS repository name. (example: bigfantech-cloud/app1)                                                                                                                                                                                     |         |
| `vcs_branch`              | VCS repository branch to use as source                                                                                                                                                                                                    |         |
| `deploy_provider`         | (ex: ECS, S3)                                                                                                                                                                                                                             |         |
| `codestar_connection_arn` | CodeStar connection ARN for CodePipeline                                                                                                                                                                                                  |         |
| `aws_chatbot_slack_arn`   | AWS ChatBot Slack client configuration ARN. AWS ChatBot Slack Client Configuration need to be done from console                                                                                                                           |         |
| `deploy_config`           | Deployment configuration<br>`ECS example:`<br>deploy_config = {<br>ClusterName = "ecs-cluster-name"<br>ServiceName = "ecs-service-name"<br>}<br>`S3 example:`<br>deploy_config = {<br>BucketName = "bucket-name"<br>Extract = "true"<br>} |         |

### Optional Variables

| Name                                       | Description                                                                                                                                                                                                                                  | Default |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `auto_detect_vcs_changes`                  | Whether to detect changes automatically when there is change in VCS branch                                                                                                                                                                   | true    |
| `codebuild_inside_vpc`                     | Enable CodeBuild inside VPC                                                                                                                                                                                                                 | false   |
| `vpc_id`                                   | VPC ID to run CodeBuild in                                                                                                                                                                                                                  | null    |
| `subnet_id`                                | List of subnet IDs to run CodeBuild in                                                                                                                                                                                                       | []      |
| `create_cloudfront_invalidation`           | Whether to create invalidation. A post deployment action will be added to CodePipeline                                                                                                                                                                                                               | false   |
| `cloudfront_id_for_invalidation`           | CloudFront distribution ID to create invalidation for<br>This is used when CloudFront + S3 deployment is done, to clear cache in edge locations  | null    |
| `stages`                                   | CodePipeline stages config. List of Map with **stage_name**, and **actions** as list.<br>For actions attributes, ref. [CodePipeline action](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline#action) | []      |
| `enable_codebuild_cloudwatch_logs`                | Enable CloudWathach log for CodeBuild                                                                                                                                                                                       | true    |
| `codebuild_cloudwatch_logs_retention_in_days` | Number in days to retain CodeBuild logs in CloudWatch | 90 |
| `enable_codebuild_s3_logs`                        | Save CodeBuild logs in S3 bucket                                                                                                                                                                                                             | false   |
| `codebuild_log_bucket_force_destroy`              | Delete all objects from CodeBuild log bucket so that the bucket can be destroyed without error                                                                                                                | false   |
| `create_codebuild_log_bucket_lifecycle` | Whether to create CodeBuild log bucket object lifecycle | true |
| `codebuild_log_bucket_lifecycle_transition_days` | Number in days after which objects are transistioned to Glacier | 90 |
| `codebuild_log_bucket_lifecycle_expiration_days` | Number in days after which objects are deleted | 180 |
| `codepipeline_artifact_bucket_force_destroy`         | Delete all objects from CodePipeline Artifact bucket, so that the bucket can be destroyed without error                                                                                                                     | false   |
| `additional_codebuild_iam_permisssions`    | List of additional permissions to attach to CodeBuild IAM policy defined in this module<br>`example:` ["ecs:*", "cloudwatch:*"]                                                                                                                             | []      |
| `additional_codepipeline_iam_permisssions` | List of additional permissions to attach to CodePipeline IAM policy defined in this module<br>`example:` ["ecs:*", "cloudwatch:*"]                                                                                                                          | []      |
| `custom_codepipeline_policy_document`      | Custom policy document for CodeBuild to attach instead of policy defined in this module.<br>Use `aws_iam_policy_document` data block to generate JSON                                                                                                                                         | null    |
| `custom_codebuild_policy_document`         | Custom policy document for CodePipeline to attach instead of policy defined in this module.<br>Use `aws_iam_policy_document` data block to generate JSON                                                                                                                                              | null    |
| `codebuild_environment_config`  | Map of CodeBuild runner environment config containing `compute_type`, `image`, `type`, `image_pull_credentials_type`, `privileged_mode` | {<br>compute_type                = "BUILD_GENERAL1_SMALL"<br>image                       = "aws/codebuild/standard:6.0"<br>type                        = "LINUX_CONTAINER"<br>image_pull_credentials_type = "CODEBUILD"<br>privileged_mode             = true<br>
    } |

### Example config

> Check the `example` folder in this repo

### Outputs

| Name                          | Description                                  |
| ----------------------------- | -------------------------------------------- |
| `codebuild_security_group_id` | Security Group attached to CodeBuild project |
| `codebuild_project_name`      | CodeBuild Project Name.                      |
| `codepipeline_arn`            | CodePipeline ARN                             |
