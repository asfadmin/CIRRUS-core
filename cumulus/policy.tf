resource "aws_sns_topic_policy" "metrics_sns_policy" {
  for_each = var.metrics_es_aws_account_id != null ? {
    "granules"    = module.cumulus.report_granules_sns_topic_arn
    "executions"  = module.cumulus.report_executions_sns_topic_arn
    "collections" = module.cumulus.report_collections_sns_topic_arn
    "pdrs"        = module.cumulus.report_pdrs_sns_topic_arn
  } : {}
  arn = each.value

  policy = data.aws_iam_policy_document.metrics_sns_topics_policy[each.key].json
}

data "aws_iam_policy_document" "metrics_sns_topics_policy" {
  policy_id = "__default_policy_ID"
  for_each = var.metrics_es_aws_account_id != null ? {
    "granules"    = module.cumulus.report_granules_sns_topic_arn
    "executions"  = module.cumulus.report_executions_sns_topic_arn
    "collections" = module.cumulus.report_collections_sns_topic_arn
    "pdrs"        = module.cumulus.report_pdrs_sns_topic_arn
  } : {}

  statement {
    actions = [
      "SNS:Subscribe",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.metrics_es_aws_account_id]
    }

    resources = [
      each.value,
    ]

    sid = "__default_statement_ID"
  }
}
