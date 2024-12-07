# Provider Configuration
provider "aws" {
  region = "us-east-1"  # Adjust this to your desired region
}

# S3 Bucket for Terraform State (with encryption and versioning enabled)
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "home-tech-terraform-state"

  # Enable versioning
  versioning {
    enabled = true
  }

  # Enable server-side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Block public access to the state bucket (highly recommended)
  block_public_access {
    block_public_acls = true
    block_public_policy = true
  }
}

# S3 Bucket for Website Hosting (public)
resource "aws_s3_bucket" "home_tech_bucket" {
  bucket = "home-tech-website"
  website {
    index_document = "index.html"
    # error_document = "error.html" # Uncomment if you have an error page
  }

  # Block public access to the website bucket
  block_public_access {
    block_public_acls = true
    block_public_policy = true
  }
}

# Upload Website Files to S3
resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.home_tech_bucket.bucket
  key    = "index.html"
  source = "index.html"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "style_css" {
  bucket = aws_s3_bucket.home_tech_bucket.bucket
  key    = "style.css"
  source = "style.css"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "contact_html" {
  bucket = aws_s3_bucket.home_tech_bucket.bucket
  key    = "contact.html"
  source = "contact.html"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "custom_tasks_html" {
  bucket = aws_s3_bucket.home_tech_bucket.bucket
  key    = "custom-tasks.html"
  source = "custom-tasks.html"
  acl    = "public-read"
}

# CloudFront Distribution (Optional, for CDN)
resource "aws_cloudfront_distribution" "home_tech_distribution" {
  origin {
    domain_name = aws_s3_bucket.home_tech_bucket.website_endpoint
    origin_id   = "home-tech-s3-origin"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/E1234567890"  # Optional, if using OAI
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Cache Behavior
  default_cache_behavior {
    target_origin_id = "home-tech-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods {
      items = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
    }
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # SSL Settings (Optional, use custom domain with SSL)
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Route 53 DNS record for custom domain (optional)
resource "aws_route53_record" "home_tech_record" {
  zone_id = "YOUR_ZONE_ID"  # Your Route 53 hosted zone ID
  name    = "www.yourdomain.com"  # The subdomain for your site (use root if you prefer)
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.home_tech_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.home_tech_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

output "website_url" {
  value = aws_s3_bucket.home_tech_bucket.website_endpoint
}
