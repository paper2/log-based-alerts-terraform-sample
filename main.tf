# 失敗するCloud Scheduler Job
resource "google_cloud_scheduler_job" "sample_fail_job" {
  name             = "sample-fail-job-${local.name_suffix}"
  description      = "Sample http job. This job always fails."
  schedule         = "*/15 * * * *"
  attempt_deadline = "300s"

  retry_config {
    retry_count = 3
    min_backoff_duration = "80s"
  }

  http_target {
    http_method = "GET"
    # This URL is not existed.
    uri = "https://goog1e"
  }
}

# 通知先
resource "google_monitoring_notification_channel" "test_notification_channel" {
  display_name = "Test Notification Channel"
  type         = "email"
  labels = {
    email_address = local.notification_channel_email
  }
}

# ログベースのアラート
resource "google_monitoring_alert_policy" "sampole_log_based_alert" {
  display_name = "Cloud Scheduler Faild Alert"
  combiner     = "OR"

  conditions {
    display_name = "Log match condition"
    condition_matched_log {
      filter = <<-EOF
      resource.type="cloud_scheduler_job"
      resource.labels.job_id="${google_cloud_scheduler_job.sample_fail_job.name}"
      severity=ERROR
      jsonPayload.@type="type.googleapis.com/google.cloud.scheduler.logging.AttemptFinished"
      EOF
    }
  }

  notification_channels = [google_monitoring_notification_channel.test_notification_channel.id]

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
    auto_close = "604800s"
  }

  documentation {
    content = "Cloud Scheduler（job_id:${google_cloud_scheduler_job.sample_fail_job.name}) faild."
  }
}