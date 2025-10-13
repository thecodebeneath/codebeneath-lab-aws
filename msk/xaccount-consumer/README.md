# Cross-account Consumer of MSK Cluster Services

After creating an MSK cluster from the `./msk` folder, it can be accessed from another account because multi-vpc private connectivity (PrivateLink) has been enabled.

### Cross-account IaC
Create a basic VPC with a public subnet and an EC2 instance to run the Kafka console CLI against the source account hosting the MSK cluster.

> The `provider.tf` file specifies using the AWS `profile` with credentials to the MSK consuming account.

```
cd ./xaccount-consumer/terraform
tofu init -reconfigure -backend-config "profile=mgmt-tf"
tofu apply -var-file=msk-consumer.tfvars
tofu destroy -var-file=msk-consumer.tfvars
```

### MSK Access

Using AWS console, click MSK > MSK Clusters > Managed VPC connections > Create connection.
1. Cluster ARN > paste PROVIDED-ARN-FROM-SOURCE-ACCOUNT > Verify
2. Select VPC w/ matching number of subset as the source cluster has brokers
3. Attach a security groups that allows outbound ports 14000-14100

```bash
Copy the value MSK > Managed VPC connections > click new entry > Cluster connection string

export KAFKA_CLUSTER_SERVERS=b-1.scram.codebeneathlabkafkaclu.1yjn08.c2.kafka.us-east-2.amazonaws.com:14001,b-2.scram.codebeneathlabkafkaclu.1yjn08.c2.kafka.us-east-2.amazonaws.com:14002
```

Run remaining steps for topic and message actions. See [../README.md](../README.md)
