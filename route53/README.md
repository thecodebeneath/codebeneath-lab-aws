# Route53
To support Gitlab runners using an OIDC provider to assume an IAM role with granular access policies, I need a publicly accesssable HTTPS URL.

## Domain Name
Register for `codebeneath-labs.org`

## DNS
Public hosted zone records
```
- gitlab.codebeneath-labs.org
```
Update domain name registrar to use AWS hosted zone nameservers (4x)

## Server Certificate
Use Let's Encrypt to issue a wildcard cert for `*.codebeneath-labs.com`
Install Certbot and the Route53 plugin, (Ref: https://certbot-dns-route53.readthedocs.io/en/stable/) then follow these steps:

```
aws sts get-session-token --duration-seconds 900
export AWS_SECRET_ACCESS_KEY=""
export AWS_ACCESS_KEY_ID=""
export AWS_SESSION_TOKEN=""
export AWS_REGION="us-east-2"

sudo --preserve-env=AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN,AWS_REGION \
     certbot certonly --dns-route53 -d "*.codebeneath-labs.org"

Certificate is saved at: /etc/letsencrypt/live/codebeneath-labs.org/*.pem
```

## Load Balancer
The AWS ALB will use the certificate to do TLS termination so that Gitlab can stay on port 80.
