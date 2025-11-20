# MSK Connect

Use MSK Connect to capture MySQL data change sets, push them through Connect to an MSK cluster topic.

Version compatibility:
- Debezium Release Series 2.7	
  - Kafka AWS Secrets Manager Config Provider (jcustenborder) 0.1.2
- MySQL 8.0.x
- MSK Kafka 3.8.x
- MSK Connect 2.7.1

## Create RDS MySQL instance

This will create a MySQL instance (Server version: 8.0.42 Source distribution)
- Free tier / "Easy create" / Create EC2 instance and connection
- Pick existing `kafka-client` EC2 instance for the connection and SG additions

### EC2 instance connection to MySQL

Prerequisities for Debezium to use MySQL

```bash
sudo dnf install mariadb105
mysql --version

mysql -h database-1.cjkskms0mtc9.us-east-2.rds.amazonaws.com -P 3306 -u admin -p

MySQL> CREATE USER 'PLACEHOLDER'@'localhost' IDENTIFIED BY 'PLACEHOLDER';
MySQL> GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT, LOCK TABLES ON *.* TO 'bob'@'localhost';
MySQL> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.005 sec)

MySQL> CREATE DATABASE testdb;
MySQL> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| testdb             |
+--------------------+

MySQL> SELECT variable_value as "BINARY LOGGING STATUS (log-bin) ::" FROM performance_schema.global_variables WHERE variable_name='log_bin';
+------------------------------------+
| BINARY LOGGING STATUS (log-bin) :: |
+------------------------------------+
| ON                                 |
+------------------------------------+

MySQL> SHOW GLOBAL VARIABLES LIKE 'server_id';
+---------------+------------+
| Variable_name | Value      |
+---------------+------------+
| server_id     | 1773682036 |
+---------------+------------+

```

## MSK Connect

### MSK Custom Plugin

Ref: https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-debeziumsource-connector-example-steps.html
Ref: https://aws.amazon.com/blogs/aws/introducing-amazon-msk-connect-stream-data-to-and-from-your-apache-kafka-clusters-using-managed-connectors/
Ref: https://github.com/aws-samples/aws-msk-cdc-data-pipeline-with-debezium/tree/main

```bash
tar xzf debezium-connector-mysql-3.3.1.Final-plugin.tar.gz
cd debezium-connector-mysql
zip -9 ../debezium-connector-mysql-3.3.1.zip *
cd ..

aws s3 cp debezium-connector-mysql-3.3.1.zip s3://codebeneath-dev/wip/
```

```bash
aws kafkaconnect create-custom-plugin --cli-input-json file://debezium-source-custom-plugin.json

aws kafkaconnect describe-custom-plugin --custom-plugin-arn "arn:aws:kafkaconnect:us-east-2:ACCNT:custom-plugin/debezium-connector-mysql-3-3-1/dda39805-78ef-4d04-b2df-0656fbcd37ed-2"
```

### Connector Service Execution Role

- Role: codebeneath-msk-connect-service-execution-role
  -- policy: AmazonMSKConnectReadOnlyAccess
  -- policy: codebeneath-allow-rds-credentials

### Connector Worker Configuration

```bash
aws kafkaconnect create-worker-configuration --name kafka-connector-worker --properties-file-content $(cat connector-worker-config.properties | base64 -w 0)
```

### Connector

```bash
aws kafkaconnect create-connector --cli-input-json file://connector-info.json
```

```bash
vi update-connector-info.json
{
   "connectorArn": <connector_arn>,
   "connectorConfiguration": <new_configuration_in_json>,
   "currentVersion": <current_version>
}

aws kafkaconnect update-connector --cli-input-json file://update-connector-info.json
aws kafkaconnect describe-connector-operation --connector-operation-arn <operation_arn>
```

