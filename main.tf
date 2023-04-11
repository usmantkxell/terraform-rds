# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name                 = "education"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "education" {
  name       = "education"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Education"
  }
}

resource "aws_security_group" "rds" {
  name   = "education_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "education_rds"
  }
}

resource "aws_db_parameter_group" "education" {
  name   = "education"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "education" {
  identifier             = "education"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.6"
  username               = "edu"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}


// CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  count               = var.create_high_cpu_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${aws_db_instance.education.identifier}-highCPUUtilization"
  comparison_operator = "GreaterThanThreshold"

  datapoints_to_alarm = var.datapoint_to_alarm
  evaluation_periods  = var.evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.cpu_utilization_too_high_threshold
  actions_enabled     = var.create_high_cpu_alarm
  alarm_description   = "Average database CPU utilization is too high."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.education.identifier
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_too_low" {
  count               = var.create_low_cpu_credit_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${aws_db_instance.education.identifier}-lowCPUCreditBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.cpu_credit_balance_too_low_threshold
  actions_enabled     = var.create_low_cpu_credit_alarm
  alarm_description   = "Average database CPU credit balance is too low, a negative performance impact is imminent."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.education.identifier
  }
  tags = var.tags
}

// Disk Utilization
resource "aws_cloudwatch_metric_alarm" "disk_queue_depth_too_high" {
  count               = var.create_high_queue_depth_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${aws_db_instance.education.identifier}-highDiskQueueDepth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.disk_queue_depth_too_high_threshold
  actions_enabled     = var.create_high_queue_depth_alarm
  alarm_description   = "Average database disk queue depth is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.education.identifier
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "disk_free_storage_space_too_low" {
  count               = var.create_low_disk_space_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${aws_db_instance.education.identifier}-lowFreeStorageSpace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.disk_free_storage_space_too_low_threshold
  actions_enabled     = var.create_low_disk_space_alarm
  alarm_description   = "Average database free storage space is too low and may fill up soon."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.education.identifier
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "disk_burst_balance_too_low" {
  count               = var.create_low_disk_burst_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${aws_db_instance.education.identifier}-lowEBSBurstBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "BurstBalance"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.disk_burst_balance_too_low_threshold
  actions_enabled     = var.create_low_disk_burst_alarm
  alarm_description   = "Average database storage burst balance is too low, a negative performance impact is imminent."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.education.identifier
  }
  tags = var.tags
}

// Memory Utilization
resource "aws_cloudwatch_metric_alarm" "memory_freeable_too_low" {
  count               = var.create_low_memory_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${aws_db_instance.education.identifier}-lowFreeableMemory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.memory_freeable_too_low_threshold
  actions_enabled     = var.create_low_memory_alarm
  alarm_description   = "Average database freeable memory is too low, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.education.identifier
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_swap_usage_too_high" {
  count               = var.create_swap_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${aws_db_instance.education.identifier}-highSwapUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.memory_swap_usage_too_high_threshold
  actions_enabled     = var.create_swap_alarm
  alarm_description   = "Average database swap usage is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.education.identifier
  }
  tags = var.tags
}

// Connection Count
resource "aws_cloudwatch_metric_alarm" "connection_count_anomalous" {
  count               = var.create_anomaly_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${aws_db_instance.education.identifier}-anomalousConnectionCount"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = var.evaluation_period
  threshold_metric_id = "e1"
  actions_enabled     = var.create_anomaly_alarm
  alarm_description   = "Anomalous database connection count detected. Something unusual is happening."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${var.anomaly_band_width})"
    label       = "DatabaseConnections (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "DatabaseConnections"
      namespace   = "AWS/RDS"
      period      = var.anomaly_period
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = aws_db_instance.education.identifier
      }
    }
  }
  tags = var.tags
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "5.6.0"

  sns_topic_name = "slack-topic"

  slack_webhook_url = ""
  slack_channel     = "aws-notification"
  slack_username    = "reporter"
}

module "aws-rds-alarms" {
  source                                    = "lorenzoaiello/rds-alarms/aws"
  version                                   = "2.2.0"
  create_low_cpu_credit_alarm               = var.create_low_cpu_credit_alarm
  create_anomaly_alarm                      = var.create_anomaly_alarm
  create_high_queue_depth_alarm             = var.create_high_queue_depth_alarm
  create_low_memory_alarm                   = var.create_low_memory_alarm
  create_high_cpu_alarm                     = var.create_high_cpu_alarm
  create_low_disk_burst_alarm               = var.create_low_disk_burst_alarm
  create_low_disk_space_alarm               = var.create_low_disk_space_alarm
  create_swap_alarm                         = var.create_swap_alarm
  cpu_utilization_too_high_threshold        = var.cpu_utilization_too_high_threshold
  disk_free_storage_space_too_low_threshold = var.disk_free_storage_space_too_low_threshold
  db_instance_id                            = aws_db_instance.education.identifier
  db_instance_class                         = aws_db_instance.education.instance_class
  actions_alarm                             = [module.notify_slack.this_slack_topic_arn]
  actions_ok                                = [module.notify_slack.this_slack_topic_arn]
}
