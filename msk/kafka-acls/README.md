# Kafka ACLs for User Alice

The MSK cluster has two users. One IAM role-based user `bob` and SCRAM user `alice`. This module adds Kafka ACL rules to restrict user `alice` operations within the cluster.

## Cluster Admin

User `bob` IAM role is the administrative privileged way to modify the cluster. IAM roles are not impacted by Kafka-managed ACLs.

## ACLS

Terraform assumes the user `bob` IAM role to perform the following in the Kafka cluster:
1. Deny `User:alice` cluster operations so that she can't modify ACLs
2. Allow `User:alice` access to all topics
3. Allow `User:alice` access to all groups
