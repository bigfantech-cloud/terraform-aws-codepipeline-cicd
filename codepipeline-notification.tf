locals {
  codepipeline_notification_event = {
    "codepipeline-pipeline-pipeline-execution-started"    = "${module.this.id} Build Initaiated"
    "codepipeline-pipeline-pipeline-execution-succeeded"  = "${module.this.id} Build Success"
    "codepipeline-pipeline-pipeline-execution-failed"     = "${module.this.id} Build Fail"
    "codepipeline-pipeline-pipeline-execution-canceled"   = "${module.this.id} Build Canceled"
    "codepipeline-pipeline-pipeline-execution-resumed"    = "${module.this.id} Build Resumed"
    "codepipeline-pipeline-pipeline-execution-superseded" = "${module.this.id} Build Superseded"
  }
  notifications_enabled = var.aws_chatbot_slack_arn == null ? false : true
}

resource "aws_codestarnotifications_notification_rule" "codepipeline" {
  for_each = local.notifications_enabled ? local.codepipeline_notification_event : {}

  detail_type    = "BASIC"
  event_type_ids = ["${each.key}"]

  name     = each.value
  resource = local.codepipeline_arn

  target {
    type    = "AWSChatbotSlack"
    address = var.aws_chatbot_slack_arn
  }

  tags = {
    project_name = var.project_name
    environment  = var.environment
  }
}
