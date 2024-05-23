data "aws_cloudfront_cache_policy" "asset-distribution-cache-policy" {
  name = "Managed-CachingOptimized"
}

resource "aws_s3_bucket" "asset-bucket" {
  bucket = var.bucket-name

  tags = {
    project = var.project-name
  }
}

resource "aws_s3_bucket_public_access_block" "asset-bucket-public-access-block" {
  bucket = aws_s3_bucket.asset-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_acm_certificate" "cloudfront-cert" {
  domain_name       = var.domain
  validation_method = "DNS"

  tags = {
    project = var.project-name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "asset-distribution" {
  comment         = "CDN for ${var.bucket-name} bucket"
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = "PriceClass_200"
  aliases         = [var.domain]
  web_acl_id      = aws_wafv2_web_acl.asset-distribution-wafv2-web-acl.arn

  origin {
    domain_name              = aws_s3_bucket.asset-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.asset-distribution-origin-access-control.id
    origin_id                = aws_s3_bucket.asset-bucket.bucket_regional_domain_name

    origin_shield {
      enabled              = true
      origin_shield_region = var.cloudfront-origin-shield-region
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.asset-distribution-cache-policy.id
    compress               = true
    target_origin_id       = aws_s3_bucket.asset-bucket.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront-cert.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = {
    project = var.project-name
  }
}

resource "aws_cloudfront_origin_access_control" "asset-distribution-origin-access-control" {
  name                              = aws_s3_bucket.asset-bucket.bucket_regional_domain_name
  description                       = "CloudFront access to ${var.bucket-name} bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_wafv2_web_acl" "asset-distribution-wafv2-web-acl" {
  name  = "${aws_s3_bucket.asset-bucket.id}-CloudFront-Metric"
  scope = "CLOUDFRONT"

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 0

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  default_action {
    allow {}
  }

  visibility_config {
    metric_name                = "${aws_s3_bucket.asset-bucket.id}-CloudFront-Metric"
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
  }
}
