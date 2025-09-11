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

resource "aws_msk_cluster" "kafka-cluster" {
  cluster_name           = "${var.project-name}-kafka-cluster"
  kafka_version          = "3.8.x"
  region                 = "us-east-2"
  storage_mode           = "LOCAL"
  number_of_broker_nodes = "2"

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    az_distribution = "DEFAULT"
    client_subnets  = [data.aws_subnet.lab-subnet-2a.id, data.aws_subnet.lab-subnet-2b.id]
    security_groups = [aws_security_group.kafka-cluster-sg.id]
    # connectivity_info {
    #   public_access {
    #     type = "DISABLED"
    #   }
    #   vpc_connectivity {
    #     client_authentication {
    #       sasl {
    #         iam   = "false"
    #         scram = "false"
    #       }
    #       tls = "false"
    #     }
    #   }
    # }
    storage_info {
      ebs_storage_info {
        volume_size = "100"
      }
    }
  }

  client_authentication {
    sasl {
      iam   = "false"
      scram = "false"
    }
    unauthenticated = "true"
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
