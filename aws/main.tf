#Basic/phase 1 resources
data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-east-1"
}

#create required s3 bucket to store log data
resource "aws_s3_bucket" "log_s3" {
  bucket = aws_s3_bucket.log_s3.id

  policy = <<POLICY

{
  "Id": "Policy1635351885113",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1635351871031",
      "Action": [
        "s3:PutBucketLogging",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::tf-cloudtrail-storage-test/*",
      "Principal": "*"
    }
  ]
}

POLICY
}

#create cloudtrail resource for application-level logs 
#send cloudtrail logs to s3 for file storage to facilitate real-time and historic activity logging 
#should have log file validation enabled

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


#VPC flow logs

#Kinesis Data Streams for ingestion?

#Kinesis Data Firehose

#aws directory services logs


#Services to create in later phases
#create guarduty resources
#create aws config resources/items
#create aws x-ray resource - tracing recommended by aws security hub foundational best practices controls
#create trusted advisor
#aws macie queries
#create aws inspector
#aws detective
#aws security hub
#ci/cd monitoring
#aws IoT device defender

