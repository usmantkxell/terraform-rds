# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


output "alarm_cpu_utilization_too_high" {
  # For older terraform support...
  value = var.create_high_cpu_alarm ? aws_cloudwatch_metric_alarm.cpu_utilization_too_high[0] : null
  # For Terraform 0.15+, eventually use this much nicer code instead...
  # value       = one(aws_cloudwatch_metric_alarm.cpu_utilization_too_high.*)
  description = "The CloudWatch Metric Alarm resource block for high CPU Utilization"
}

output "alarm_cpu_credit_balance_too_low" {
  # For older terraform support...
  value = var.create_low_cpu_credit_alarm ? length(regexall("(t2|t3)", aws_db_instance.education.instance_class)) > 0 ? aws_cloudwatch_metric_alarm.cpu_credit_balance_too_low[0] : null : null
  # For Terraform 0.15+, eventually use this much nicer code instead...
  # value       = one(aws_cloudwatch_metric_alarm.cpu_credit_balance_too_low.*)
  description = "The CloudWatch Metric Alarm resource block for low CPU Credit Balance"
}

output "alarm_disk_queue_depth_too_high" {
  # For older terraform support...
  value = var.create_high_queue_depth_alarm ? aws_cloudwatch_metric_alarm.disk_queue_depth_too_high[0] : null
  # For Terraform 0.15+, eventually use this much nicer code instead...
  # value       = one(aws_cloudwatch_metric_alarm.disk_queue_depth_too_high.*)
  description = "The CloudWatch Metric Alarm resource block for high Disk Queue Depth"
}

output "alarm_disk_free_storage_space_too_low" {
  # For older terraform support...
  value = var.create_low_disk_space_alarm ? aws_cloudwatch_metric_alarm.disk_free_storage_space_too_low[0] : null
  # For Terraform 0.15+, eventually use this much nicer code instead...
  # value       = one(aws_cloudwatch_metric_alarm.disk_free_storage_space_too_low.*)
  description = "The CloudWatch Metric Alarm resource block for low Free Storage Space"
}

output "alarm_disk_burst_balance_too_low" {
  # For older terraform support...
  value = var.create_low_disk_burst_alarm ? aws_cloudwatch_metric_alarm.disk_burst_balance_too_low[0] : null
  # For Terraform 0.15+, eventually use this much nicer code instead...
  # value       = one(aws_cloudwatch_metric_alarm.disk_burst_balance_too_low.*)
  description = "The CloudWatch Metric Alarm resource block for low Disk Burst Balance"
}

output "alarm_memory_freeable_too_low" {
  # For older terraform support...
  value = var.create_low_memory_alarm ? aws_cloudwatch_metric_alarm.memory_freeable_too_low[0] : null
  # For Terraform 0.15+, eventually use this much nicer code instead...
  # value       = one(aws_cloudwatch_metric_alarm.memory_freeable_too_low.*)
  description = "The CloudWatch Metric Alarm resource block for low Freeable Memory"
}

output "alarm_memory_swap_usage_too_high" {
  # For older terraform support...
  value = var.create_swap_alarm ? aws_cloudwatch_metric_alarm.memory_swap_usage_too_high[0] : null
  # For Terraform 0.15+, eventually use this much nicer code instead...
  # value       = one(aws_cloudwatch_metric_alarm.memory_swap_usage_too_high.*)
  description = "The CloudWatch Metric Alarm resource block for high Memory Swap Usage"
}

output "alarm_connection_count_anomalous" {
  # For older terraform support...
  value = var.create_anomaly_alarm ? aws_cloudwatch_metric_alarm.connection_count_anomalous[0] : null
  # For Terraform 0.15+, eventually use this much nicer code instead...
  # value       = one(aws_cloudwatch_metric_alarm.connection_count_anomalous.*)
  description = "The CloudWatch Metric Alarm resource block for anomalous Connection Count"
}
output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.education.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.education.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.education.username
  sensitive   = true
}

