data "aws_vpc" "lab-vpc" {
    filter {
      name   = "tag:Name"
      values = [var.project-name]
    }
}

data "aws_subnet" "lab-subnet-2a" {
    filter {
      name   = "tag:Name"
      values = ["${var.project-name}-public-2a"]
    }
}

data "aws_subnet" "lab-subnet-2b" {
    filter {
      name   = "tag:Name"
      values = ["${var.project-name}-public-2b"]
    }
}

data "aws_iam_policy_document" "allow-msk-multivpc-connectivity" {
  statement {
    sid = "AWSKafkaMultivpcConnectivityPolicy"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kafka:CreateVpcConnection",
      "kafka:GetBootstrapBrokers",
      "kafka:DescribeCluster",
      "kafka:DescribeClusterV2"
    ]
    resources = [
      "${aws_msk_cluster.kafka-cluster.arn}"
    ]
  }
}

resource "aws_msk_configuration" "kafka-config" {
  name           = "${var.project-name}-kafka-config"
  description    =  "Appends Kafka broker property to allow SASL/SCRAM to be used for multi-vpc private connection clients"
  kafka_versions = ["3.8.x"]

  server_properties = <<PROPERTIES
auto.create.topics.enable=false
default.replication.factor=3
min.insync.replicas=2
num.io.threads=8
num.network.threads=5
num.partitions=1
num.replica.fetchers=2
replica.lag.time.max.ms=30000
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
socket.send.buffer.bytes=102400
unclean.leader.election.enable=false
allow.everyone.if.no.acl.found=false
PROPERTIES
}

resource "aws_msk_cluster" "kafka-cluster" {
  cluster_name           = "${var.project-name}-kafka-cluster"
  kafka_version          = "3.8.x"
  region                 = "us-east-2"
  storage_mode           = "LOCAL"
  number_of_broker_nodes = "2"

  configuration_info {
    arn = aws_msk_configuration.kafka-config.arn
    revision = aws_msk_configuration.kafka-config.latest_revision
  }

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    az_distribution = "DEFAULT"
    client_subnets  = [data.aws_subnet.lab-subnet-2a.id, data.aws_subnet.lab-subnet-2b.id]
    security_groups = [aws_security_group.kafka-cluster-sg.id]

    # multi-vpc private connectivity settings
    connectivity_info {
      public_access {
        type = "DISABLED"
      }
      vpc_connectivity {
        client_authentication {
          sasl {
            iam   = "true"
            scram = "true"
          }
          tls = "false"
        }
      }
    }

    storage_info {
      ebs_storage_info {
        volume_size = "10"
      }
    }
  }

  client_authentication {
    sasl {
      iam   = "true"
      scram = "true"
    }
    unauthenticated = "false"
  }

#   encryption_info {
#     encryption_at_rest_kms_key_arn = "arn:aws:kms:us-east-2:732457136693:key/61b952d6-cf95-4ceb-a9c6-0cbc163eb57c"
#     encryption_in_transit {
#       client_broker = "PLAINTEXT"
#       in_cluster    = "true"
#     }
#   }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled = "false"
      }

      firehose {
        enabled = "false"
      }

      s3 {
        enabled = "false"
      }
    }
  }

  enhanced_monitoring = "DEFAULT"
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = "false"
      }

      node_exporter {
        enabled_in_broker = "false"
      }
    }
  }
}

resource "aws_msk_cluster_policy" "msk-cluster-policy" {
  cluster_arn = aws_msk_cluster.kafka-cluster.arn
  policy = data.aws_iam_policy_document.allow-msk-multivpc-connectivity.json

}

resource "aws_security_group" "kafka-cluster-sg" {
  name        = "${var.project-name}-kafka-cluster-sg"
  description = "Security group and rules for the Lab VPC kafka cluster"
  vpc_id      = data.aws_vpc.lab-vpc.id

  tags = {
    Name = "${var.project-name}-kafka-cluster-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-kafka-client-ec2" {
  description                  = "Allow inbound traffic to the Lab VPC kafka cluster from the kafka client ec2"
  security_group_id            = aws_security_group.kafka-cluster-sg.id
  referenced_security_group_id = aws_security_group.kafka-client-sg.id
  ip_protocol                  = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow-cluster-all-traffic-ipv4" {
  description       = "Allow all outbound traffic from Lab VPC kafka cluster"
  security_group_id = aws_security_group.kafka-cluster-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
