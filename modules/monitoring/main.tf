# SLO Monitoring — alarms for success rate and latency, SNS for alerting

resource "aws_sns_topic" "alerts" {
  name = "${var.project}-slo-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# SLO: 99.9% success rate
# Fires when 5xx errors exceed 0.1% of total requests.

resource "aws_cloudwatch_metric_alarm" "success_rate" {
  alarm_name        = "${var.project}-slo-success-rate"
  alarm_description = "5xx error rate exceeds 0.1% - SLO breach"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 0.1
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "error_rate"
    expression  = "(target_5xx / requests) * 100"
    label       = "Error rate %"
    return_data = true
  }

  metric_query {
    id = "target_5xx"
    metric {
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
      dimensions  = { TargetGroup = var.target_group_arn_suffix, LoadBalancer = var.alb_arn_suffix }
    }
  }

  metric_query {
    id = "requests"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
      dimensions  = { LoadBalancer = var.alb_arn_suffix }
    }
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

# SLO: 99.9% of responses under 300ms
# Fires when p99.9 latency exceeds 300ms.

resource "aws_cloudwatch_metric_alarm" "latency" {
  alarm_name        = "${var.project}-slo-latency-p999"
  alarm_description = "p99.9 response time exceeds 300ms - SLO breach"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 0.3 # seconds
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  treat_missing_data  = "notBreaching"

  metric_name        = "TargetResponseTime"
  namespace          = "AWS/ApplicationELB"
  period             = 60
  extended_statistic = "p99.9"
  dimensions         = { TargetGroup = var.target_group_arn_suffix, LoadBalancer = var.alb_arn_suffix }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
