# Configure CloudWatch to monitor the EC2 instances
#Alarme de alta utilizacao do CPU
resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "rodry-cw-tf"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "93"
  alarm_description   = "This metric monitors the CPU utilization of the EC2 instances."
  alarm_actions       = ["arn:aws:sns:us-east-2:746108472597:my-cloudwatch-sns-topic"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }
}

#Alarme de alto inbound traffic
resource "aws_cloudwatch_metric_alarm" "network_inbound_alarm" {
  alarm_name          = "rodry-cw-tf-network-inbound"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000000"
  alarm_description   = "This metric monitors the inbound network traffic of the EC2 instances."
  alarm_actions       = ["arn:aws:sns:us-east-2:746108472597:my-cloudwatch-sns-topic"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }
}

#Alarme de alto outbound traffic
resource "aws_cloudwatch_metric_alarm" "network_outbound_alarm" {
  alarm_name          = "rodry-cw-tf-network-outbound"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000000"
  alarm_description   = "This metric monitors the outbound network traffic of the EC2 instances."
  alarm_actions       = ["arn:aws:sns:us-east-2:746108472597:my-cloudwatch-sns-topic"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }
}

#Alarme de alto disk space utilization
resource "aws_cloudwatch_metric_alarm" "disk_space_utilization_alarm" {
  alarm_name          = "rodry-cw-tf-disk-space-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors the disk space utilization of the EC2 instances."
  alarm_actions       = ["arn:aws:sns:us-east-2:746108472597:my-cloudwatch-sns-topic"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }
}

#Alarme de alto memory utilization
resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm" {
  alarm_name          = "rodry-cw-tf-memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors the memory utilization of the EC2 instances."
  alarm_actions       = ["arn:aws:sns:us-east-2:746108472597:my-cloudwatch-sns-topic"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }
}

#Alarme de alto disk read/write operations
resource "aws_cloudwatch_metric_alarm" "disk_rw_operations_alarm" {
  alarm_name          = "rodry-cw-tf-disk-rw-operations"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskReadOps"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "This metric monitors the disk read/write operations of the EC2 instances."
  alarm_actions       = ["arn:aws:sns:us-east-2:746108472597:my-cloudwatch-sns-topic"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }
}


#Alarme de alto status check failed
resource "aws_cloudwatch_metric_alarm" "status_check_failed_alarm" {
  alarm_name          = "rodry-cw-tf-status-check-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors the number of status check failures of the EC2 instances."
  alarm_actions       = ["arn:aws:sns:us-east-2:746108472597:my-cloudwatch-sns-topic"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }
}

#Alarme de low cpu credit balance
resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_alarm" {
  alarm_name          = "rodry-cw-tf-cpu-credit-balance"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "10"
  alarm_description   = "This metric monitors the CPU credit balance of the EC2 instances."
  alarm_actions       = ["arn:aws:sns:us-east-2:746108472597:my-cloudwatch-sns-topic"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }
}
