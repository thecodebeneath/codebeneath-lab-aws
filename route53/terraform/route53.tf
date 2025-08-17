#
# Experimental terraform import and HCL generation with the import blocks below.
# Ref: https://developer.hashicorp.com/terraform/language/import/generating-configuration
#   > terraform plan -generate-config-out=generated.tf
# The generated.tf content is then copied here and improved.
#

# ========== temp import blocks ==========

# import {
#   to = aws_route53_zone.codebeneath-labs-org 
#   id = "Z0109069JX5UL8PLW0N1"
# }

# import {
#   to = aws_route53_record.gitlab 
#   id = "Z0109069JX5UL8PLW0N1_gitlab.codebeneath-labs.org_A_"
# }

# ========== copied from generated.tf ==========

data "aws_lb" "gitlab-alb" {
  name = var.gitlab-alb-name
}

resource "aws_route53_zone" "codebeneath-labs-org" {
  #checkov:skip=CKV2_AWS_39:Ensure Domain Name System query logging is enabled for hosted zones
  #checkov:skip=CKV2_AWS_38:Ensure DNSSEC signing is enabled for public hosted zones
  name = var.lab-zone-name
}

resource "aws_route53_record" "gitlab" {
  zone_id = aws_route53_zone.codebeneath-labs-org.zone_id
  name    = var.gitlab-record-name
  type    = "A"
  alias {
    name                   = data.aws_lb.gitlab-alb.dns_name
    zone_id                = data.aws_lb.gitlab-alb.zone_id
    evaluate_target_health = false
  }
}
