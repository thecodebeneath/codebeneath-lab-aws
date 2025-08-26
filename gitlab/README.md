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

If using [AWS Cognito Integration for User Logins](#aws-cognito-integration-for-user-logins), set these env vars:
```bash
export USER_POOL_ID=$(aws cognito-idp list-user-pools --max-results 1 | jq -r .UserPools[0].Id)
export OAUTH_CLIENT_ID=$(aws cognito-idp list-user-pool-clients --user-pool-id "$USER_POOL_ID" --max-results 1 | jq -r .UserPoolClients[0].ClientId)
export OAUTH_CLIENT_SECRET=$(aws cognito-idp describe-user-pool-client --user-pool-id "$USER_POOL_ID" --client-id "$OAUTH_CLIENT_ID" | jq -r .UserPoolClient.ClientSecret)
export COGNITO_CLIENT_DOMAIN=$(aws cognito-idp describe-user-pool --user-pool-id "$USER_POOL_ID" | jq -r .UserPool.Domain)
```

```bash
export ECR_REGISTRY="$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.us-east-2.amazonaws.com"
aws ecr get-login-password | docker login -u AWS --password-stdin "https://$ECR_REGISTRY"

cd ~/gitlab
Copy the "docker-compose.yaml" file here...

docker compose up -d
docker compose ps
```

# Usage

## Root user
```bash
docker compose exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

## Cognito user
1. Click the button to sign in with > "Codebeneath Cognito"
2. Click "Sign up" and fill in the form. Profile, email and phone can be bogus as they won't be automatically confirmed
3. Cancel the confirm account dialog
4. From AWS Console, Cognito > User pools > gitlab-user-pool > Users > new user
5. Edit the user to confirm account and verify email and phone
6. Login to gitlab as the new user

# Gitlab Runners

## OIDC Provider
The Gitlab runner uses OIDC identity provider permissions to assume a specific Gitlab runner IAM role.
```
cd ./gitlab/oidc-provider/terraform
terraform apply -var-file=codebeneath.tfvars
```

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

# AWS Cognito Integration for User Logins
Cognito can be used to manage user pools and Oauth2 client apps.
- Ref: https://docs.gitlab.com/administration/auth/cognito/

## Create the Cognito User Pool
TBD

## Configure the Gitlab Server
```
docker compose exec -it gitlab bash

cd /etc/gitlab
vi gitlab.rb
```

Gitlab config updated with Cognito client id, client secret and Cognito URLs:
```
### OmniAuth Settings
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_allow_single_sign_on'] = ['cognito']
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_external_providers'] = ['cognito']
gitlab_rails['omniauth_providers'] = [
  {
    name: "cognito",
    label: "Codebeneath Cognito", # optional label for login button, defaults to "Cognito"
    icon: nil,
    app_id: "PLACEHOLDER",
    app_secret: "PLACEHOLDER",
    args: {
      scope: "openid email profile",
      client_options: {
        site: "https://COGNITO_CLIENT_DOMAIN.auth.us-east-2.amazoncognito.com",
        authorize_url: "/oauth2/authorize",
        token_url: "/oauth2/token",
        user_info_url: "/oauth2/userInfo"
      },
      user_response_structure: {
        root_path: [],
        id_path: ["sub"],
        attributes: { nickname: "email", name: "email", email: "email" }
      },
      name: "cognito",
      strategy_class: "OmniAuth::Strategies::OAuth2Generic"
    }
  }
]
```

Restart Gitlab with config changes:
```
gitlab-ctl reconfigure
```

# Stop Gitlab Server with Docker Compose
```bash
docker compose down
```
