# Prerequisites

```bash
export ECR_REGISTRY="$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.us-east-2.amazonaws.com"
aws ecr get-login-password | docker login -u AWS --password-stdin "https://$ECR_REGISTRY"

docker pull gitlab/gitlab-ce
docker tag gitlab/gitlab-ce "$ECR_REGISTRY"/gitlab/gitlab-ce
docker push "$ECR_REGISTRY"/gitlab/gitlab-ce

docker pull gitlab/gitlab-runner:alpine
docker tag gitlab/gitlab-runner:alpine "$ECR_REGISTRY"/gitlab/gitlab-runner:alpine
docker push "$ECR_REGISTRY"/gitlab/gitlab-runner:alpine

# docker pull python:alpine
# docker tag python:alpine "$ECR_REGISTRY"/python:alpine
# docker push "$ECR_REGISTRY"/python:alpine

# docker pull hashicorp/terraform
# docker tag hashicorp/terraform "$ECR_REGISTRY"/hashicorp/terraform
# docker push "$ECR_REGISTRY"/hashicorp/terraform
```

# Start Gitlab on public IP of the host

```bash
export ECR_REGISTRY="$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.us-east-2.amazonaws.com"
aws ecr get-login-password | docker login -u AWS --password-stdin "https://$ECR_REGISTRY"

export TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
export PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
export ECR_REGISTRY="$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.us-east-2.amazonaws.com"
export RUNNER_REG_TOKEN=$(echo $RANDOM | md5sum | head -c 20)

Copy the "docker-compose.yaml" file here...

docker compose up -d
docker compose ps
```

# Usage
```bash
docker compose exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

# Runners

## Host-based Runner
Makes use of the Amazon ECR Credential Helper (`docker-credential-ecr-login`) to use EC2 instance role for Docker login to ECR.

```
sudo curl -L --output /usr/local/bin/gitlab-runner "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-linux-amd64"

sudo chmod +x /usr/local/bin/gitlab-runner
```

As Gitlab root user: Admin > CI > Runners > Create Runner > Save

Then copy the provided token value for use in the next command:
```
sudo gitlab-runner register \
    --non-interactive \
    --url 'https://gitlab.codebeneath-labs.org' \
    --token glrt-93VQhUEuqFJ7ApkUVPJvR286MQp0OjEKdToxCw.01.121r35qvu \
    --executor 'docker' \
    --docker-image 'python:alpine' \
    --docker-network-mode 'host' \
    --env DOCKER_AUTH_CONFIG='{ "credsStore": "ecr-login" }'
	
sudo gitlab-runner run

```

## Docker Runner (and dynamic, nested job runner) 
A single Gitlab runner, running as a docker container, will register itself with the gitlab server using a registration token. The token is randomly generated and injected into the docker-compose.yml file.

> The registration token method is deprecated and is now replaced with using a personal access token (root) during runner registration.

# Stop Gitlab
```bash
docker compose down
```
