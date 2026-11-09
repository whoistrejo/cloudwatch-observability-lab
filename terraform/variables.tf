variable "aws_region" { type = string, default = "us-east-1" }
variable "instance_id" { type = string, description = "Existing EC2 instance ID in this region." }
variable "alarm_email" { type = string, default = "", description = "Optional email for SNS alarm notifications." }
