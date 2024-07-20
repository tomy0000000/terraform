data "aws_cloudfront_cache_policy" "asset-distribution-cache-policy" {
  name = "Managed-CachingOptimized"
}

data "aws_iam_policy_document" "allow_access_from_s3_with_referer" {
  version   = "2008-10-17"
  policy_id = "PolicyForCloudFrontPrivateContent"

  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.asset-bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::514253011358:distribution/E21W24AGN042XK"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:Referer"
      values   = formatlist("%s/*", var.access-urls)
    }
  }
}

resource "aws_s3_bucket" "asset-bucket" {
  bucket = var.bucket-name

  tags = {
    project = var.project-name
  }
}

resource "aws_s3_bucket_policy" "asset-bucket-policy" {
  bucket = aws_s3_bucket.asset-bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_s3_with_referer.json
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
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.asset-distribution-cache-policy.id
    compress                 = true
    origin_request_policy_id = aws_cloudfront_origin_request_policy.asset-distribution-origin-request-policy.id
    target_origin_id         = aws_s3_bucket.asset-bucket.bucket_regional_domain_name
    viewer_protocol_policy   = "redirect-to-https"
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

resource "aws_cloudfront_origin_request_policy" "asset-distribution-origin-request-policy" {
  name    = "Managed-UserAgentRefererHeaders"
  comment = "Policy to forward user-agent and referer headers to origin"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["user-agent", "referer"]
    }
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}
