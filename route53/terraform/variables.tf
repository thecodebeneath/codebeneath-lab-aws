variable lab-zone-name {
  type        = string
  default     = "codebeneath-labs.org"
  description = "Zone domain name for lab instances"
}

variable gitlab-record-name {
  type        = string
  default     = "gitlab.codebeneath-labs.org"
  description = "Zone record name for the Gitlab instance"
}

variable gitlab-alb-name {
  type        = string
  nullable    = false
  description = "Load balancer name for the Gitlab instance"
}
