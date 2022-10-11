output "bucket_domain" {
  value = "https://${aws_s3_bucket.demo_bucket.bucket_domain_name}"
}

output "website_url" {
  value = "http://${var.domain_url}"
}
