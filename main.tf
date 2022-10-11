terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
//  access_key = ""
//  secret_key = ""
}

# Can possibly be replaced with the template module.
# https://registry.terraform.io/modules/hashicorp/dir/template/latest
locals {
  type_by_ext = {
    "css"  = "text/css"
    "html" = "text/html"
    "js"   = "application/javascript"
    "txt"  = "text/plain"
  }
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.domain_url
  acl    = "public-read"

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.domain_url}/*"
    }
  ]
}
EOF

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name        = var.domain_url
    Environment = "demo"
  }
}

# DNS stuff
resource "aws_route53_record" "demo_domain" {
  zone_id = var.zone_id
  name    = "${var.domain_url}."
  type    = "A"

  alias {
    name                   = aws_s3_bucket.demo_bucket.website_domain
    zone_id                = aws_s3_bucket.demo_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}

# Load the source files.
resource "aws_s3_bucket_object" "index" {
  for_each     = fileset("${path.root}/${var.static_dir}", "*")
  content_type = lookup(local.type_by_ext, split(".", each.value)[1], local.type_by_ext["txt"])
  bucket       = aws_s3_bucket.tm_bucket.bucket
  key          = each.value
  source       = "${path.root}/${var.static_dir}/${each.value}"
  etag         = filemd5("${path.root}/${var.static_dir}/${each.value}")
}