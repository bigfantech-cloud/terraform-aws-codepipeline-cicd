#----
#CODEBUILD
#----

resource "aws_s3_bucket" "codebuild" {
  count = var.enable_codebuild_s3_logs ? 1 : 0

  bucket        = "${module.this.id}-codebuild-log"
  force_destroy = var.codebuild_log_bucket_force_destroy

  tags = module.this.tags
}

resource "aws_s3_bucket_ownership_controls" "codebuild" {
  count = var.enable_codebuild_s3_logs ? 1 : 0

  bucket = aws_s3_bucket.codebuild[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "codebuild" {
  count = var.enable_codebuild_s3_logs ? 1 : 0

  bucket                  = aws_s3_bucket.codebuild[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
  
resource "aws_s3_bucket_lifecycle_configuration" "codebuild_log" {
  count      = var.create_codebuild_log_bucket_lifecycle ? 1 : 0

  bucket = aws_s3_bucket.codebuild[0].id

  rule {
    id = "expiration-${var.codebuild_log_bucket_lifecycle_expiration_days}"

    status = "Enabled"

    transition {
      days          = var.codebuild_log_bucket_lifecycle_transition_days
      storage_class = "GLACIER"
    }
    expiration {
      days = var.codebuild_log_bucket_lifecycle_expiration_days
    }
}

#----
#CODEPIPELINE
#----

resource "aws_s3_bucket" "codepipeline" {
  bucket        = "${module.this.id}-artifacts"
  force_destroy = var.codepipeline_artifact_bucket_force_destroy

  tags = module.this.tags
}

resource "aws_s3_bucket_ownership_controls" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "codepipeline" {
  bucket                  = aws_s3_bucket.codepipeline.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
