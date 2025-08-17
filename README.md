# Codebeneath AWS Lab

Terraform to standup the Codebeneath lab AWS resources

# Table of Contents
1. [AWS Resources](#aws-resources)
2. [Security, Policy and Linting Scans](#security-policy-and-linting-scans)
3. [Reverse Engineer IaC](#reverse-engineer-iac)

## AWS Resources

All AWS resources for the lab are managed by Terraform.

### VPC
Create the lab base networking resources.
> As an example multi-environment module, resources can be created in `aws` or a `localstack` environment.

#### AWS Environment
```
cd ./vpc/terraform
terraform -chdir=./env/aws init
terraform -chdir=./env/aws apply -var-file=codebeneath.tfvars

aws ec2 describe-vpc-endpoints
terraform -chdir=./env/aws destroy -var-file=codebeneath.tfvars
```

#### Localstack Environment
```
cd ./vpc/terraform
docker compose -f ./env/localstack/docker-compose.yaml up -d
terraform -chdir=./env/localstack init
terraform -chdir=./env/localstack apply -var-file=localstack.tfvars

aws ec2 describe-vpc-endpoints --endpoint-url http://localhost:4566
terraform -chdir=./env/localstack destroy -var-file=localstack.tfvars
docker compose -f ./env/localstack/docker-compose.yaml down
```

### Bootstrap Server
Create the Bootstrap EC2 server with Docker and extra /data volume
```
cd ./bootstrap/terraform
terraform init
terraform apply -var-file=codebeneath.tfvars
terraform destroy -var-file=codebeneath.tfvars
```

### VPN
Provision AWS client VPN for access to the lab subnets

> Pricing is per VPC association $0.10/hr and client connection $0.05/hr

Reference for VPC setup and custom CA: [AWS Client VPN](https://medium.com/@rishi_abhishek/aws-vpn-client-endpoint-connection-4a09799fdd89)

```
cd ./vpn/terraform
terraform init
terraform apply -var-file=codebeneath.tfvars
terraform destroy -var-file=codebeneath.tfvars
```

### Container Registry
Create image repositories used in the lab

```
cd ./ecr/terraform
terraform init
terraform apply -var-file=codebeneath.tfvars
terraform destroy -var-file=codebeneath.tfvars
```

### Gitlab Instance
Create a self-hosted gitlab instance in the lab public subnet
```
cd ./gitlab/terraform
terraform init
terraform apply -var-file=codebeneath.tfvars
terraform destroy -var-file=codebeneath.tfvars

<manual docker compose steps>

cd ./gitlab/oidc-provider/terraform
terraform init
terraform apply -var-file=codebeneath.tfvars
terraform destroy -var-file=codebeneath.tfvars
```

## Security, Policy and Linting Scans
Checkov scans:
```
cd to a ./terraform folder
docker run -t --rm -v $(pwd):/tf --workdir /tf bridgecrew/checkov --directory /tf

terraform plan -var-file=codebeneath.tfvars -out tfplan.bin
terraform show -json tfplan.bin | jq > tfplan.json
docker run -t --rm -v $(pwd):/tf --workdir /tf bridgecrew/checkov -f tfplan.json
```

tflint scans
```
cd to a ./terraform folder
docker run -t --rm -v $(pwd):/data --entrypoint "/bin/sh" ghcr.io/terraform-linters/tflint -c "tflint --init && tflint"
```

## Reverse Engineer IaC

### Terraformer 
Terraformer project
Ref: https://github.com/GoogleCloudPlatform/terraformer
```bash
terraformer import aws -r route53
```
The generated .tf files are created in `./generated/aws/route53/*.tf`

### Terraform native
Experimental terraform import and HCL generation with the import blocks below.
Ref: https://developer.hashicorp.com/terraform/language/import/generating-configuration
```bash
terraform plan -generate-config-out=generated.tf
```
The `generated.tf` content is then copied here and improved.

