# Codebeneath AWS Lab

Terraform to standup the Codebeneath lab AWS resources

## VPC
Create the lab base networking resources
```
cd ./vpc/terraform
terraform init
terraform apply -var-file=codebeneath.tfvars
terraform destroy -var-file=codebeneath.tfvars
```

## Bootstrap Server
Create the Bootstrap EC2 server with Docker and extra /data volume
```
cd ./bootstrap/terraform
terraform init
terraform apply -var-file=codebeneath.tfvars
terraform destroy -var-file=codebeneath.tfvars
```

## VPN
Provision AWS client VPN for access to the lab subnets

> Pricing is per VPC association $0.10/hr and client connection $0.05/hr

Reference for VPC setup and custom CA: [AWS Client VPN](https://medium.com/@rishi_abhishek/aws-vpn-client-endpoint-connection-4a09799fdd89)

```
cd ./vpn/terraform
terraform init
terraform apply -var-file=codebeneath.tfvars
terraform destroy -var-file=codebeneath.tfvars
```

## Gitlab Instance
Create a self-hosted gitlab instance in the lab public subnet
```
cd ./gitlab/terraform
terraform init
terraform apply -var-file=codebeneath.tfvars
terraform destroy -var-file=codebeneath.tfvars
```
