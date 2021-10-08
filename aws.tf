data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-east-2"
}

#create required s3 bucket to store log data
resource "aws_s3_bucket" "log_s3" {
  bucket = "tf-cloudtrail-storage-test"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::tf-test-trail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::tf-test-trail/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
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


#create guarduty resources
