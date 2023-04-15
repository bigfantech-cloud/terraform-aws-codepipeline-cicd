output "codebuild_security_group_id" {
  description = "Security Group attached to CodeBuild project"
  value       = var.codebuild_inside_vpc ? aws_security_group.codebuild_sg[0].id : null
}

output "codebuild_project_name" {
  description = "CodeBuild Project Name"
  value       = aws_codebuild_project.default.name
}

output "codepipeline_arn" {
  description = "CodePipeline ARN"
  value       = local.codepipeline_arn
}
