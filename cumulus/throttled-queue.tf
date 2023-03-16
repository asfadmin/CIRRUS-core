resource "aws_sqs_queue" "background_job_queue" {
  name                       = "${local.prefix}-backgroundJobQueue"
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = 60
  tags                       = local.default_tags
}

resource "aws_cloudwatch_event_rule" "background_job_queue_watcher" {
  name                = "${local.prefix}-background_job_queue_watcher"
  schedule_expression = "rate(1 minute)"
  tags                = local.default_tags
}

resource "aws_cloudwatch_event_target" "background_job_queue_watcher" {
  rule = aws_cloudwatch_event_rule.background_job_queue_watcher.name
  arn  = module.cumulus.sqs2sfThrottle_lambda_function_arn
  input = jsonencode({
    messageLimit = 500
    queueUrl     = aws_sqs_queue.background_job_queue.id
    timeLimit    = 60
  })
}

resource "aws_lambda_permission" "background_job_queue_watcher" {
  action        = "lambda:InvokeFunction"
  function_name = module.cumulus.sqs2sfThrottle_lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.background_job_queue_watcher.arn
}
