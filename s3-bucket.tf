#----
#CODEBUILD
#----

resource "aws_s3_bucket" "codebuild" {
  count = var.codebuild_s3_logs ? 1 : 0

  bucket        = "${module.this.id}-codebuild-log"
  force_destroy = var.cb_log_bucket_force_destroy

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}-codebuild"
    }
  )
}

resource "aws_s3_bucket_ownership_controls" "codebuild" {
  count = var.codebuild_s3_logs ? 1 : 0

  bucket = aws_s3_bucket.codebuild[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "codebuild" {
  count = var.codebuild_s3_logs ? 1 : 0

  bucket                  = aws_s3_bucket.codebuild[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#----
#CODEPIPELINE
#----

resource "aws_s3_bucket" "codepipeline" {
  bucket        = "${module.this.id}-artifacts"
  force_destroy = var.cp_artifact_bucket_force_destroy

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}-artifacts"
    }
  )
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
