data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-east-1"
}

#create required s3 bucket to store log data
resource "aws_s3_bucket" "log_s3" {
  bucket = "tf-cloudtrail-storage-test"

  policy = <<POLICY {
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
      "Resource": "arn:aws:s3:::tf-cloudtrail-storage-test/prefix/AWSLogs",
      "Principal": {
        "AWS": [
          "tf-cloudtrail-storage-test"
        ]
      }
    }
  ]
}
POLICY
}
#create cloudtrail resource
resource "aws_cloudtrail" "cloudtrail" {
  name                          = "TF_cloudtrail"
  s3_bucket_name                = aws_s3_bucket.log_s3.id
  include_global_service_events = true
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


#create aws config resources


#create aws x-ray resources


#create trusted advisor

#aws macie queries

#create aws inspector

#ci/cd monitoring


#VPC flow logs - find a way to collect them
