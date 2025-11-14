# IAM Role Module

This module creates an IAM role with flexible configuration options for various AWS services and use cases.

## Features

- Create IAM roles with customizable trust policies
- Support for service principals (EC2, Lambda, ECS, etc.)
- Support for cross-account role assumptions
- Attach AWS managed policies
- Create and attach custom policies
- Inline policies support
- Optional EC2 instance profile creation
- Configurable assume role conditions
- Comprehensive tagging

## Usage Examples

### Basic EC2 Role

```hcl
module "ec2_role" {
  source = "./modules/iam-role"

  role_name        = "my-ec2-role"
  role_description = "Role for EC2 instances"

  trusted_services = ["ec2.amazonaws.com"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  create_instance_profile = true

  tags = {
    Environment = "dev"
  }
}
```

### Lambda Function Role

```hcl
module "lambda_role" {
  source = "./modules/iam-role"

  role_name        = "my-lambda-role"
  role_description = "Role for Lambda function"

  trusted_services = ["lambda.amazonaws.com"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  custom_policies = {
    s3_access = {
      name        = "lambda-s3-access"
      description = "Allow Lambda to access S3"
      policy      = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject"
            ]
            Resource = "arn:aws:s3:::my-bucket/*"
          }
        ]
      })
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### ECS Task Role

```hcl
module "ecs_task_role" {
  source = "./modules/iam-role"

  role_name        = "my-ecs-task-role"
  role_description = "Role for ECS tasks"

  trusted_services = ["ecs-tasks.amazonaws.com"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  tags = {
    Environment = "staging"
  }
}
```

### Cross-Account Role

```hcl
module "cross_account_role" {
  source = "./modules/iam-role"

  role_name        = "cross-account-role"
  role_description = "Role for cross-account access"

  trusted_role_arns = [
    "arn:aws:iam::123456789012:root"
  ]

  assume_role_conditions = [
    {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["unique-external-id"]
    }
  ]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = {
    Purpose = "Cross-account access"
  }
}
```

### Role with Custom Assume Role Policy

```hcl
module "custom_role" {
  source = "./modules/iam-role"

  role_name        = "custom-trust-policy-role"
  role_description = "Role with custom trust policy"

  custom_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| role_name | Name of the IAM role | string | - | yes |
| role_description | Description of the IAM role | string | "" | no |
| role_path | Path for the IAM role | string | "/" | no |
| max_session_duration | Maximum session duration in seconds | number | 3600 | no |
| force_detach_policies | Force detach policies before destroying | bool | false | no |
| custom_assume_role_policy | Custom assume role policy JSON | string | null | no |
| trusted_services | AWS services that can assume the role | list(string) | [] | no |
| trusted_role_arns | Role ARNs that can assume this role | list(string) | [] | no |
| assume_role_conditions | Conditions for assume role policy | list(object) | [] | no |
| managed_policy_arns | AWS managed policy ARNs to attach | list(string) | [] | no |
| custom_policies | Custom policies to create and attach | map(object) | {} | no |
| inline_policies | Inline policies to embed | list(object) | [] | no |
| policy_path | Path for IAM policies | string | "/" | no |
| create_instance_profile | Create EC2 instance profile | bool | false | no |
| instance_profile_name | Instance profile name | string | null | no |
| tags | Additional tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | ARN of the IAM role |
| role_name | Name of the IAM role |
| role_id | ID of the IAM role |
| role_unique_id | Unique ID of the IAM role |
| instance_profile_arn | ARN of instance profile (if created) |
| instance_profile_name | Name of instance profile (if created) |
| instance_profile_id | ID of instance profile (if created) |
| custom_policy_arns | ARNs of custom policies created |
| custom_policy_ids | IDs of custom policies created |

## Common AWS Service Principals

- EC2: `ec2.amazonaws.com`
- Lambda: `lambda.amazonaws.com`
- ECS Tasks: `ecs-tasks.amazonaws.com`
- ECS Service: `ecs.amazonaws.com`
- CodeBuild: `codebuild.amazonaws.com`
- CodePipeline: `codepipeline.amazonaws.com`
- API Gateway: `apigateway.amazonaws.com`
- CloudWatch Events: `events.amazonaws.com`
- Step Functions: `states.amazonaws.com`
- Glue: `glue.amazonaws.com`
- SageMaker: `sagemaker.amazonaws.com`
