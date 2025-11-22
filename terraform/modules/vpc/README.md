# VPC Module

This module creates a complete AWS VPC infrastructure with public and private subnets across multiple availability zones.

## Features

- VPC with configurable CIDR block
- Public and private subnets distributed across availability zones
- Internet Gateway for public subnet internet access
- NAT Gateways for private subnet internet access (optional)
- Route tables configured for both subnet types
- DNS support enabled by default

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  name     = "my-app"
  vpc_cidr = "10.0.0.0/16"
  az_count = 2

  enable_nat_gateway = true

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix for VPC resources | string | - | yes |
| vpc_cidr | CIDR block for VPC | string | - | yes |
| az_count | Number of availability zones to use | number | 2 | no |
| enable_dns_hostnames | Enable DNS hostnames in the VPC | bool | true | no |
| enable_dns_support | Enable DNS support in the VPC | bool | true | no |
| enable_nat_gateway | Enable NAT Gateway for private subnets | bool | true | no |
| map_public_ip_on_launch | Auto-assign public IP in public subnets | bool | true | no |
| tags | Additional tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr | CIDR block of the VPC |
| public_subnet_ids | List of IDs of public subnets |
| private_subnet_ids | List of IDs of private subnets |
| nat_gateway_ids | List of IDs of NAT Gateways |
| internet_gateway_id | ID of the Internet Gateway |
