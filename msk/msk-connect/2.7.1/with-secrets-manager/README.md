# MSK Connect

Use MSK Connect to capture MySQL data change sets, push them through Connect to an MSK cluster topic.

Version compatibility:
- Debezium Release Series 2.7	
  - Kafka AWS Secrets Manager Config Provider (jcustenborder) 0.1.2
- MySQL 8.0.x
- MSK Kafka 2.7.1
- MSK Connect 2.7.1

## Create RDS MySQL instance

### RDS Parameter Group

For MySQL, Debezium requires binlog_format to be set to "ROW".

Create a new parameter group:
 - Parameter group name: `mysql-for-msk-connect-debezium`
 - Description: `mysql-for-msk-connect-debezium`
 - Engine type: `MySQL Community`
 - Parameter group family: `mysql8.0`
 - Type: `DB Parameter Group`

Edit the new parameter group "mysql-for-msk-connect-debezium"
 - binlog_format: `ROW`

### RDS cluster

This will create a MySQL instance (Server version: 8.0.42 Source distribution)
- Free tier / "Easy create" / Parameter group "mysql-for-msk-connect-debezium" / Create EC2 instance and connection
- Pick existing `kafka-client` EC2 instance for the connection and SG additions

### EC2 instance connection to MySQL

Prerequisities for Debezium to use MySQL

```bash
sudo dnf install mariadb105
mysql --version

mysql -h database-1.cjkskms0mtc9.us-east-2.rds.amazonaws.com -P 3306 -u admin -p

MySQL> CREATE USER 'PLACEHOLDER'@'localhost' IDENTIFIED BY 'PLACEHOLDER';
MySQL> CREATE USER 'PLACEHOLDER'@'%' IDENTIFIED BY 'PLACEHOLDER';
MySQL> GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT, LOCK TABLES ON *.* TO 'PLACEHOLDER'@'localhost';
MySQL> GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT, LOCK TABLES ON *.* TO 'PLACEHOLDER'@'%';
MySQL> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.005 sec)

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

Create a database and table to monitor for changes:
```bash
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

MySQL> CREATE TABLE testdb.student
(
    student_id int(10) not null,
    student_first_name varchar(20) not null,
    student_last_name varchar(20)not null
);

MySQL> CREATE TABLE testdb.teacher
(
    student_id int(10) not null,
    student_first_name varchar(20) not null,
    student_last_name varchar(20)not null
);

MySQL> insert into testdb.student values (7,'Bob','Alice');
MySQL> insert into testdb.teacher values (9,'The','Codebeneath');
```

### Secrets Manager for User

Secret type: `Credentials for Amazon RDS database`
Credentials: `username & password`
Encryption key: `default`
Database: `RDS MySQL instance`
Secret name: `codebeneath/mysql/user`

## MSK Connect

### MSK Custom Plugin

Ref: https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-debeziumsource-connector-example-steps.html
Ref: https://aws.amazon.com/blogs/aws/introducing-amazon-msk-connect-stream-data-to-and-from-your-apache-kafka-clusters-using-managed-connectors/
Ref: https://github.com/aws-samples/aws-msk-cdc-data-pipeline-with-debezium/tree/main

```bash
cd plugin
wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/2.7.4.Final/debezium-connector-mysql-2.7.4.Final-plugin.tar.gz
tar xzf debezium-connector-mysql-2.7.4.Final-plugin.tar.gz
wget https://hub-downloads.confluent.io/api/plugins/jcustenborder/kafka-config-provider-aws/versions/0.1.2/jcustenborder-kafka-config-provider-aws-0.1.2.zip
unzip jcustenborder-kafka-config-provider-aws-0.1.2.zip -d debezium-connector-mysql
cd debezium-connector-mysql
zip -9 -r ../debezium-connector-mysql-secrets-manager-2.7.4.zip *
cd ..

aws s3 cp debezium-connector-mysql-secrets-manager-2.7.4.zip s3://codebeneath-dev/wip/
```

```bash
aws kafkaconnect create-custom-plugin --cli-input-json file://debezium-source-custom-plugin.json

aws kafkaconnect describe-custom-plugin --custom-plugin-arn "arn:aws:kafkaconnect:us-east-2:ACCNT:custom-plugin/debezium-connector-mysql-3-3-1/dda39805-78ef-4d04-b2df-0656fbcd37ed-2"
```

### Connector Service Execution Role

- Role: codebeneath-msk-connect-service-execution-role
  -- policy: codebeneath-allow-rds-credentials
  -- policy: codebeneath-msk-connect-service-execution-allow
  -- policy: codebeneath-msk-connect-service-executor-cloudwatch
  -- policy: kafka-connect-service-role-policy

### Connector Worker Configuration

```bash
aws kafkaconnect create-worker-configuration --name kafka-connector-worker-secrets-manager --properties-file-content $(cat connector-worker-config.properties | base64 -w 0)
```

### Connector

```bash
aws kafkaconnect create-connector --cli-input-json file://connector-info.json

aws kafkaconnect describe-connector --connector-arn arn:aws:kafkaconnect:us-east-2:ACCNT:connector/codebeneath-debezium-source-connector/d29b0974-d3cf-442f-ab2a-56e835c5ad99-2
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

