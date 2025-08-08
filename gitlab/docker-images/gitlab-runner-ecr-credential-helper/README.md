# Gitlab runner docker image with ECR credential helper

> Note: Can't get this runner image to work with the ECR credential helper.

```bash
export AWS_REGION=us-east-2
export ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text)
aws ecr get-login-password | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com

docker build -t $ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/codebeneath/gitlab/gitlab-runner-ecr-helper:1.0 .
docker push $ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/codebeneath/gitlab/gitlab-runner-ecr-helper:1.0
```