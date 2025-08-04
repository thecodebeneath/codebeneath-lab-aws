variable lab-zone-name {
  type        = string
  default     = "codebeneath-labs.org"
  description = "Zone domain name for lab instances"
}

variable gitlab-record-name {
  type        = string
  default     = "gitlab"
  description = "Zone record name for the Gitlab instance"
}

variable lb-dns-name {
  type        = string
  nullable    = false
  description = "Load balancer DNS name for the Gitlab instance"
}
