variable project-name {
  type        = string
  default     = "codebeneath-lab"
  description = "A string used for all resource names"
}

variable vpn-client-cidr-block {
  type        = string
  default     = "10.50.0.0/22"
  description = "The IPv4 address range, in CIDR notation, from which to assign client IP addresses"
}

variable vpn-server-cert-domain {
  type        = string
  default     = "vpn.codebeneath.org"
  description = "Domain name for the VPN server cert"
}

variable vpn-client-cert-domain {
  type        = string
  default     = "client.codebeneath.org"
  description = "Domain name for the VPN client cert"
}
