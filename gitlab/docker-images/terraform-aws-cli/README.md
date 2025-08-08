# Gitlab executor docker image with AWS CLI for OIDC temp creds

```bash
export AWS_REGION=us-east-2
export ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text)
aws ecr get-login-password | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com

docker build -t $ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/codebeneath/hashicorp/terraform-awscli:1.0 .
docker push $ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/codebeneath/hashicorp/terraform-awscli:1.0
```