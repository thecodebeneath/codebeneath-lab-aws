# Managed Streaming Kafka
This module will create a Kafka cluster with 2 nodes. It allows access only from the cooresponding Kafka client ec2 instance.

Ref: [Get Started with Amazon Managed Streaming for Apache Kafka (MSK) | Amazon Web Services](https://www.youtube.com/watch?v=5WaIgJwYpS8)

# MSK Cluster Config

The MSK cluster has these relevant configurations:
1. The cluster has two client authentication methods enabled:
   1. SASL/SCRAM. This username/password scheme is tested by user `alice`
   2. IAM. This IAM role-based scheme is tested by user `bob`
2. The cluster is enabled for multi-vpc private connectivity, so that it can be accessed from other VPCs or accounts
   1. Multi-vpc rivate connectivity also has both authentication methods enabled: SASL/SCRAM and IAM
   2. The external/consumer account must create a MSK > Managed VPC Connection to the cluster
   3. The MSK cluster owner must accept the managed VPC connection request 

## Kafka Client EC2 Setup
```
# newer versions of java changed how the it's SecurityManager is used
sudo yum install java-17-amazon-corretto-devel

wget https://archive.apache.org/dist/kafka/3.8.1/kafka_2.12-3.8.1.tgz
tar -xvf kafka_2.12-3.8.1.tgz 

# set region to "us-east-2", leave everything else blank
aws configure

aws kafka list-clusters
```

## Kafka Client Topic and Message Testing

### User `Alice` - SCRAM Auth

User `alice` connects to the MSK cluster using client_authentication method `scram`. Note that the MSK cluster brokers have unique endpoints for IAM connections `BootstrapBrokerStringSaslScram`.

Create a topic
```
export KAFKA_CLUSTER_ARN=$(aws kafka list-clusters | jq -r '.ClusterInfoList[0].ClusterArn')
export KAFKA_CLUSTER_SERVERS=$(aws kafka get-bootstrap-brokers --cluster-arn "$KAFKA_CLUSTER_ARN" | jq -r '.BootstrapBrokerStringSaslScram')
export KAFKA_TOPIC="CodebeneathTopic"

Get the Secrets Manager secret value from "AmazonMSK_codebeneath-lab-msk-scram-secret"

cat > /home/ec2-user/users_jaas.conf<<EOF
KafkaClient {
   org.apache.kafka.common.security.scram.ScramLoginModule required
   username="alice"
   password="PLACEHOLDER";
};
EOF

cat > /home/ec2-user/client_sasl.properties<<EOF
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
EOF

export KAFKA_OPTS="-Djava.security.auth.login.config=/home/ec2-user/users_jaas.conf -Xmx1G"

cd kafka_2.12-3.8.1/bin

./kafka-topics.sh --create --bootstrap-server "$KAFKA_CLUSTER_SERVERS" --command-config /home/ec2-user/client_sasl.properties --replication-factor 2 --partitions 1 --topic "$KAFKA_TOPIC"

./kafka-topics.sh --bootstrap-server "$KAFKA_CLUSTER_SERVERS" --command-config /home/ec2-user/client_sasl.properties --list
```

#### Producer runs from this shell
```
./kafka-console-producer.sh --bootstrap-server "$KAFKA_CLUSTER_SERVERS" --command-config /home/ec2-user/client_sasl.properties --topic "$KAFKA_TOPIC"
exit
```

#### Consumer runs from another shell
```
./kafka-console-consumer.sh --bootstrap-server "$KAFKA_CLUSTER_SERVERS" --command-config /home/ec2-user/client_sasl.properties --topic "$KAFKA_TOPIC" --from-beginning
exit
```
### User `Bob` - SCRAM Auth

User `bob` connects to the MSK cluster using client_authentication method `iam`. Note that the MSK cluster brokers have unique endpoints for IAM connections `BootstrapBrokerStringSaslIam`.

Create a topic
```
export KAFKA_CLUSTER_ARN=$(aws kafka list-clusters | jq -r '.ClusterInfoList[0].ClusterArn')
export KAFKA_CLUSTER_SERVERS=$(aws kafka get-bootstrap-brokers --cluster-arn "$KAFKA_CLUSTER_ARN" | jq -r '.BootstrapBrokerStringSaslIam')
export KAFKA_TOPIC="CodebeneathTopic"

TODO:
  - create aws config profile for `bob` or
  - aws sts assume-role --role-arn arn:aws:iam::ACCNT:role/codebeneath-lab-kafka-client-auth-bob-role --role-session-name kafka-iam-client-auth, then export AWS_* ENVs

cat > /home/ec2-user/client_sasl.properties<<EOF
security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required awsProfileName=bob;
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
EOF

cd kafka_2.12-3.8.1/bin

./kafka-topics.sh --create --bootstrap-server "$KAFKA_CLUSTER_SERVERS" --command-config /home/ec2-user/client_sasl.properties --replication-factor 2 --partitions 1 --topic "$KAFKA_TOPIC"

./kafka-topics.sh --bootstrap-server "$KAFKA_CLUSTER_SERVERS" --command-config /home/ec2-user/client_sasl.properties --list
```

#### Producer runs from this shell
```
./kafka-console-producer.sh --bootstrap-server "$KAFKA_CLUSTER_SERVERS" --command-config /home/ec2-user/client_sasl.properties --topic "$KAFKA_TOPIC"
exit
```

#### Consumer runs from another shell
```
./kafka-console-consumer.sh --bootstrap-server "$KAFKA_CLUSTER_SERVERS" --command-config /home/ec2-user/client_sasl.properties --topic "$KAFKA_TOPIC" --from-beginning
exit
```
