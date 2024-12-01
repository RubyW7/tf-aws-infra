# tf-aws-infra

This project uses Terraform to configure and deploy AWS networking resources, including a VPC, subnets, route tables, and an Internet Gateway. Follow the steps below to initialize, apply, and destroy these resources.

## Prerequisites

Before running the Terraform configuration, ensure you have the following:

- [Terraform installed](https://www.terraform.io/downloads.html).
- AWS CLI configured with your credentials (in `~/.aws/credentials`) or AWS environment variables set (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).
- This repository cloned or downloaded, with the terminal open in the project root directory.

## Project Structure

The main files in this project are:

- `provider.tf`: Defines the AWS provider configuration.
- `variables.tf`: Defines dynamic configuration variables.
- `main.tf`: Invokes the `networking` module and passes in required variables.
- `networking/` folder: Contains resources for networking, including VPC, subnets, route tables, etc.

## Deployment Steps

### 1. Initialize Terraform

To initialize Terraform and download necessary provider plugins, run:

```bash
terraform init
```

### 2. Create Networking Resources
For example:
```bash
terraform apply -var-file="prod.tfvars"
```

### 3. Clean Up Networking Resources
For example:
```bash
terraform destroy -var-file="prod.tfvars"
```

### re-init:
```bash
rm -rf .terraform
rm terraform.tfstate terraform.tfstate.backup
```