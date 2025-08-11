# Prerequisites

Docker images available in ECR repos
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

# Start Gitlab Server with Docker Compose

```bash
export ECR_REGISTRY="$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.us-east-2.amazonaws.com"
aws ecr get-login-password | docker login -u AWS --password-stdin "https://$ECR_REGISTRY"

cd ~/gitlab
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
Install the Gitlab runner as a service and make use of the Amazon ECR Credential Helper (`docker-credential-ecr-login`) to use EC2 instance role for Docker login to ECR.

As Gitlab root user, create a personal access token:
- Administrator > Edit profile > Access tokens > Add new token
  - Token name: runner-token
  - Scopes: create_runner, manage_runner
- Create token
- Copy token

```bash
cd ~/gitlab
Copy the "register-gitlab-runner.sh" file here...

export GITLAB_ACCESS_TOKEN="<ACCESSTOKEN>"
./register-gitlab-runner.sh
```

## Docker Runner (and dynamic, nested job runner) 
A single Gitlab runner, running as a docker container, will register itself with the gitlab server using a registration token. The token is randomly generated and injected into the docker-compose.yml file.

> The registration token method is deprecated and is now replaced with using a personal access token (root) during runner registration.

# Stop Gitlab Server with Docker Compose
```bash
docker compose down
```
