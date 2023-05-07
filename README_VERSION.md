# v1.1.0

## Feature addition

#### what changed:

- S3 bucket lifecycle added to CodeBuild log bucket
- CodeBuild runner environment is made as var.

#### reason for change:

#### info:

New variables:

`codebuild_environment_config`: Map of CodeBuild runner environment config containing `compute_type`, `image`, `type`, `image_pull_credentials_type`, `privileged_mode`

```
    Default = {
      compute_type                         = "BUILD_GENERAL1_SMALL"
      image                                       = "aws/codebuild/standard:6.0"
      type                                          = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
      privileged_mode                     = true
    }
```

- `enable_codebuild_cloudwatch_logs`: Enable CloudWathach log for CodeBuild. Default = true
- `codebuild_cloudwatch_logs_retention_in_days`: Number in days to retain CodeBuild logs in CloudWatch. Default = 90
- `enable_codebuild_s3_logs`: Save CodeBuild logs in S3 bucket. Default = false

# v1.0.0

### Major

Initial release.
