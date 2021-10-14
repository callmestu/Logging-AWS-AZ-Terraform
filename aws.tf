data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-east-1"
}

#create required s3 bucket to store log data
resource "aws_s3_bucket" "log_s3" {
  bucket = aws_s3_bucket.log_s3.id

  policy = <<POLICY 
{
  "Id": "Policy1633988374100",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1633988361678",
      "Action": [
        "s3:GetBucketAcl",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": aws_s3bocket.log_s3.arn/tf-cloudtrail-storage-test/prefix/AWSLogs/*",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      }
    }
  ]
}
POLICY
}

#create cloudtrail resource - should have log file validation enabled
#send cloudtrail logs to s3 for file storage, send to cloudwatch to facilitate real-time and historic activity logging 
resource "aws_cloudtrail" "cloudtrail" {
  name                          = "TF_cloudtrail"
  s3_bucket_name                = aws_s3_bucket.log_s3.id
  include_global_service_events = true
  #CloudWatchLogsLogGroupArn 
}

#create cloudwatch resource
resource "aws_cloudwatch_log_group" "cloudwatch_group" {
  name = "TF_cloudwatch"

  tags = {
    Environment = "test"
    Application = "testAppService"
  }
}

#create guarduty resources


#create aws config resources/items


#create aws x-ray resource - tracing recommended by aws security hub foundational best practices controls


#create trusted advisor

#aws macie queries

#create aws inspector

#aws detective

#aws security hub

#ci/cd monitoring

#VPC flow logs - find a way to collect them

#aws directory services logs

#aws IoT device defender

