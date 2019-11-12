data "aws_acm_certificate" "just_for_redirect_01" {
  provider = "aws.virginia"  #from:aws.tf
  domain = "${var.ssl_domain["just_for_redirect_01_from"]}"
  statuses = ["ISSUED"]
}
