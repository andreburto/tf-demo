output "bucket_domain" {
  value = "${aws_s3_bucket.demo_bucket.website_domain}"
}