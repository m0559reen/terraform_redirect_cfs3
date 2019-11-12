variable "domain" {
    default = {
      "just_for_redirect_01_from" = "hoge.com"
      "just_for_redirect_01_to"   = "fuga.com"
    }
}

variable "ssl_domain" {
    default = {
      "just_for_redirect_01_from" = "*.hoge.com"
    }
}

variable "s3_bucket_name" {
    default = {
        "just_for_redirect_01" = "redirect-to-fugacom"
    }
}