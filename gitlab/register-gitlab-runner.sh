#!/bin/bash

#
# GITLAB_ACCESS_TOKEN is created from Root login > Admin > Profile > Access tokens
#

declare RUNNER_TOKEN

RUNNER_TOKEN=$(curl --silent --request POST --url 'https://gitlab.codebeneath-labs.org/api/v4/user/runners' \
  --data 'runner_type=instance_type' \
  --data 'description=codebeneath-lab-runner' \
  --data 'tag_list=python,tf' \
  --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" | jq -r .token)

#  {"id":5,"token":"glrt-lWGXJOU20Pz5j0zF3Zo7Lm86MQp0OjEKdToxCw.01.120bxevr0","token_expires_at":null}

sudo gitlab-runner register \
  --non-interactive \
  --url 'https://gitlab.codebeneath-labs.org' \
  --token "$RUNNER_TOKEN" \
  --executor 'docker' \
  --docker-image 'python:alpine' \
  --docker-network-mode 'host' \
  --env DOCKER_AUTH_CONFIG='{ "credsStore": "ecr-login" }'
	
sudo systemctl restart gitlab-runner
