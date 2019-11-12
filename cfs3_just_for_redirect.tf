###### S3

resource "aws_s3_bucket" "just_for_redirect_01" {
  bucket = "${var.s3_bucket_name["just_for_redirect_01"]}"
  acl = "private"
  website {
    index_document = "index.html"
    routing_rules = <<EOF
[{
  "Redirect": {
    "Protocol":"https",
    "HostName":"${var.domain["just_for_redirect_01_to"]}"
    }
}]
EOF
  }
}

resource "aws_s3_bucket_policy" "just_for_redirect_01" {
    bucket = "${aws_s3_bucket.just_for_redirect_01.id}"
    policy =  <<POLICY
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.just_for_redirect_01.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.just_for_redirect_01.arn}/*"
        }
    ]
}
POLICY
}

###### CloudFront

resource "aws_cloudfront_origin_access_identity" "just_for_redirect_01" {
  comment = "${var.s3_bucket_name["just_for_redirect_01"]}"
}

resource "aws_cloudfront_distribution" "just_for_redirect_01" {
  http_version = "http1.1"
  price_class = "PriceClass_All"
  comment = "redirect from ${var.domain["just_for_redirect_01_from"]} to ${var.domain["just_for_redirect_01_to"]}"
  aliases = ["${var.domain["just_for_redirect_01_from"]}"]
  enabled = true

  origin {
    domain_name = "${aws_s3_bucket.just_for_redirect_01.id}.s3-website-ap-northeast-1.amazonaws.com"
    origin_id   = "S3-${aws_s3_bucket.just_for_redirect_01.id}"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_read_timeout = "30"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = "S3-${aws_s3_bucket.just_for_redirect_01.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }

    }

    viewer_protocol_policy = "allow-all"
    compress               = false
    default_ttl            = "0"
    min_ttl                = "0"
    max_ttl                = "0"
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.just_for_redirect_01.arn}"
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method = "sni-only"
  }
  custom_error_response {
    error_code = 400
    error_caching_min_ttl = "0"
  }
  custom_error_response {
    error_code = 404
    error_caching_min_ttl = "0"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
