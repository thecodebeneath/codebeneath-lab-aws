# EC2 Instance Connect

This module will create an EC2 instance and allow accessing it using an EC2 Instance Connect Endpoint.

## SSH From Workstation

This allows connecting to the instance using an IAM role from a workstation

### Allowed SSH Role

The IAM role must have these identity-based policies:
- ec2-instance-connect:SendSSHPublicKey
- ec2-instance-connect:OpenTunnel
- ec2:DescribeInstances
- ec2:DescribeInstanceConnectEndpoints

```bash
~/.aws/config

[profile eice-workstation-role]
region = us-east-2
```

```bash
~/.aws/credentials

[eice-workstation-role]
role_arn = arn:aws:iam::ACCNT:role/codebeneath-lab-eice-workstation-role
source_profile = default
```

Using the role, use the EC2 Instance Connection Endpoint (eice) to get a shell on the instance:
```bash
aws ec2-instance-connect ssh --instance-id i-0fe146c279ced0e8b --profile eice-workstation-role
```


## SSH From AWS Console

This allow connecting to the instance using the AWS Console in a browser:

AWS Console > EC2 > Instance > Connect > EC2 Instance Connect tab > Connect using a Private IP
