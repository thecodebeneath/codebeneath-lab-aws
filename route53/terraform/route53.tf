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

resource "aws_route53_zone" "codebeneath-labs-org" {
  name = var.lab-zone-name
}

resource "aws_route53_record" "gitlab" {
  zone_id = aws_route53_zone.codebeneath-labs-org.zone_id
  name    = var.gitlab-record-name
  type    = "A"
  alias {
    name                   = var.alb-dns-name
    zone_id                = var.alb-zone-id
    evaluate_target_health = false
  }
}

# resource "aws_acm_certificate" "wildcard-codebeneath-labs-org" {
#   private_key       = file("./ssh/privkey1.pem")
#   certificate_body  = file("./ssh/cert1.pem")
#   certificate_chain = file("./ssh/chain1.pem")
# }
