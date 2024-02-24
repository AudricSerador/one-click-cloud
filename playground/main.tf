terraform {
}

provider "aws"{
region = "us-east-2"
}

resource "aws_s3_bucket" "s3"{
bucket_prefix = "stratus-"
}

resource "aws_s3_object" "s3"{
for_each = fileset("./tf_test_folder", "**")
bucket = "${aws_s3_bucket.s3.bucket}"
key = "${each.value}"
source = "./tf_test_folder/${each.value}"
content_type = "${each.value}"
}

resource "aws_s3_bucket_cors_configuration" "s3"{
bucket = "${aws_s3_bucket.s3.bucket}"
cors_rule {
allowed_headers = [
"*"
]
allowed_methods = [
"GET",
"HEAD"
]
allowed_origins = [
"*"
]
expose_headers = [
"ETag"
]
max_age_seconds = 3000
}
}

resource "aws_s3_bucket_acl" "s3"{
bucket = "${aws_s3_bucket.s3.bucket}"
acl = "public-read"
depends_on = [
aws_s3_bucket_ownership_controls.s3
]
}

resource "aws_s3_bucket_ownership_controls" "s3"{
bucket = "${aws_s3_bucket.s3.bucket}"
rule {
object_ownership = "BucketOwnerPreferred"
}
}

resource "aws_iam_user" "s3"{
name = "prod-s3-bucket"
}

resource "aws_s3_bucket_public_access_block" "s3"{
bucket = "${aws_s3_bucket.s3.bucket}"
block_public_acls = false
block_public_policy = false
ignore_public_acls = false
restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3"{
bucket = "${aws_s3_bucket.s3.bucket}"
policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Principal\":\"*\",\"Action\":[\"s3:*\"],\"Effect\":\"Allow\",\"Resource\":[\"arn:aws:s3:::${aws_s3_bucket.s3.bucket}\",\"arn:aws:s3:::${aws_s3_bucket.s3.bucket}/*\"]},{\"Sid\":\"PublicReadGetObject\",\"Principal\":\"*\",\"Action\":[\"s3:GetObject\"],\"Effect\":\"Allow\",\"Resource\":[\"arn:aws:s3:::${aws_s3_bucket.s3.bucket}\",\"arn:aws:s3:::${aws_s3_bucket.s3.bucket}/*\"]}]}"
depends_on = [
aws_s3_bucket_public_access_block.s3
]
}

resource "aws_s3_bucket_website_configuration" "s3"{
bucket = "${aws_s3_bucket.s3.bucket}"
index_document {
suffix = "index.html"
}
}

output "bucket_website_endpoint"{
value = "${aws_s3_bucket_website_configuration.s3.website_endpoint}"
}

