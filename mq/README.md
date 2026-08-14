# AmazonMQ / ActiveMQ
This module will create a single MQ ActiveMQ broker. Used to test a lambda that reboots the broker.

### Terraform ###

Provision a simple MQ broker using a SINGLE_INSTANCE deployment mode
```
cd ./mq/terraform
tofu init
tofu apply -var-file=codebeneath.tfvars

tofu output -raw mq_broker_username
tofu output -raw mq_broker_password
```
