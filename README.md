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

## Container Registry
Create image repositories used in the lab

```
cd ./ecr/terraform
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

## Reverse Engineer IaC

### Terraform native
Experimental terraform import and HCL generation with the import blocks below.
Ref: https://developer.hashicorp.com/terraform/language/import/generating-configuration
```bash
terraform plan -generate-config-out=generated.tf
```
The `generated.tf` content is then copied here and improved.

### Terraformer 
Terraformer project
Ref: https://github.com/GoogleCloudPlatform/terraformer
```bash
terraformer import aws -r route53
```
The generated .tf files are created in `./generated/aws/route53/*.tf`
