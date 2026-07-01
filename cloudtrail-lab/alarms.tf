# IAM role that allows CloudTrail to write to CloudWatch Logs
resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "cloudtrail-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
    }]
  })
}

# Gives the role permission to write logs
resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "cloudtrail-cloudwatch-policy"
  role = aws_iam_role.cloudtrail_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
    }]
  })
}

# Connects CloudTrail to CloudWatch so logs flow through
resource "aws_cloudtrail" "main_updated" {
  name                          = "grc-lab-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch.arn

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]
}

# ALARM 1: Root account login
# Fires when anyone logs into AWS as the root user
# Maps to CIS AWS Foundations 1.7
resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "root-login-filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ $.userIdentity.type = \"Root\" && $.eventType != \"AwsServiceEvent\" }"

  metric_transformation {
    name      = "RootLoginCount"
    namespace = "GRCLab/SecurityAlerts"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login" {
  alarm_name          = "root-account-login"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RootLoginCount"
  namespace           = "GRCLab/SecurityAlerts"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Root account login detected — CIS AWS 1.7"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# ALARM 2: IAM policy changes
# Fires when anyone creates, deletes, or modifies an IAM policy
# Maps to CIS AWS Foundations 3.4
resource "aws_cloudwatch_log_metric_filter" "iam_changes" {
  name           = "iam-changes-filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)}"

  metric_transformation {
    name      = "IAMPolicyChangeCount"
    namespace = "GRCLab/SecurityAlerts"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_changes" {
  alarm_name          = "iam-policy-changes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "IAMPolicyChangeCount"
  namespace           = "GRCLab/SecurityAlerts"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "IAM policy change detected — CIS AWS 3.4"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# ALARM 3: Unauthorized API calls
# Fires when someone tries to do something they don't have permission for
# Maps to CIS AWS Foundations 3.1
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api" {
  name           = "unauthorized-api-filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{($.errorCode=AccessDenied)||($.errorCode=UnauthorizedOperation)}"

  metric_transformation {
    name      = "UnauthorizedAPICount"
    namespace = "GRCLab/SecurityAlerts"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api" {
  alarm_name          = "unauthorized-api-calls"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAPICount"
  namespace           = "GRCLab/SecurityAlerts"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Unauthorized API calls detected — CIS AWS 3.1"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
