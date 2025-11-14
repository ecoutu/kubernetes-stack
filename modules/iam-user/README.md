# IAM User Module

This module creates an IAM user with flexible configuration options including console access, programmatic access, and group memberships.

## Features

- Create IAM users with custom paths
- Optional console access (login profile)
- Optional programmatic access (access keys)
- Attach AWS managed policies
- Create and attach custom policies
- Inline policies support
- Group membership management
- SSH public key for CodeCommit access
- Comprehensive outputs including credentials (marked as sensitive)
- Configurable force destroy option

## Usage Examples

### Basic User with Console Access

```hcl
module "user_console" {
  source = "./modules/iam-user"

  user_name = "john.doe"

  create_login_profile    = true
  password_reset_required = true

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = {
    Department = "Engineering"
    Team       = "DevOps"
  }
}
```

### User with Programmatic Access

```hcl
module "user_programmatic" {
  source = "./modules/iam-user"

  user_name = "ci-cd-user"

  create_access_key = true

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]

  tags = {
    Purpose = "CI/CD Pipeline"
  }
}
```

### User with Custom Policies

```hcl
module "user_custom" {
  source = "./modules/iam-user"

  user_name = "app-user"

  create_access_key = true

  custom_policies = {
    s3_specific = {
      name        = "app-user-s3-access"
      description = "Allow access to specific S3 buckets"
      policy      = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject",
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::my-app-bucket",
              "arn:aws:s3:::my-app-bucket/*"
            ]
          }
        ]
      })
    }
  }

  tags = {
    Application = "MyApp"
  }
}
```

### User with Group Memberships

```hcl
# Assuming groups already exist
module "user_groups" {
  source = "./modules/iam-user"

  user_name = "team-member"

  create_login_profile    = true
  password_reset_required = true

  group_memberships = [
    "developers",
    "readonly-users"
  ]

  tags = {
    Team = "Development"
  }
}
```

### User with SSH Key for CodeCommit

```hcl
module "user_codecommit" {
  source = "./modules/iam-user"

  user_name = "git-user"

  ssh_public_key = file("~/.ssh/id_rsa.pub")
  ssh_key_status = "Active"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeCommitPowerUser"
  ]

  tags = {
    Purpose = "CodeCommit Access"
  }
}
```

### Administrator User

```hcl
module "admin_user" {
  source = "./modules/iam-user"

  user_name = "admin"
  user_path = "/admins/"

  create_login_profile    = true
  password_reset_required = true
  force_destroy           = false

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  tags = {
    Role = "Administrator"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| user_name | Name of the IAM user | string | - | yes |
| user_path | Path for the IAM user | string | "/" | no |
| force_destroy | Destroy user even if it has non-Terraform resources | bool | false | no |
| create_login_profile | Create console access for the user | bool | false | no |
| password_reset_required | Require password reset on first login | bool | true | no |
| create_access_key | Create access key for programmatic access | bool | false | no |
| managed_policy_arns | AWS managed policy ARNs to attach | list(string) | [] | no |
| custom_policies | Custom policies to create and attach | map(object) | {} | no |
| inline_policies | Inline policies to embed | list(object) | [] | no |
| policy_path | Path for IAM policies | string | "/" | no |
| group_memberships | IAM group names to add user to | list(string) | [] | no |
| ssh_public_key | SSH public key for CodeCommit | string | null | no |
| ssh_key_encoding | SSH key encoding format (SSH or PEM) | string | "SSH" | no |
| ssh_key_status | SSH key status (Active or Inactive) | string | "Active" | no |
| tags | Additional tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| user_arn | ARN of the IAM user |
| user_name | Name of the IAM user |
| user_unique_id | Unique ID assigned by AWS |
| login_profile_encrypted_password | Encrypted console password (sensitive) |
| access_key_id | Access key ID (sensitive) |
| access_key_secret | Access key secret (sensitive) |
| access_key_status | Access key status |
| ssh_key_id | SSH key ID |
| ssh_key_fingerprint | SSH key fingerprint |
| custom_policy_arns | ARNs of custom policies created |
| custom_policy_ids | IDs of custom policies created |

## Important Notes

### Credential Management

- **Console Password**: The encrypted password is available in outputs. Use `terraform output -raw login_profile_encrypted_password` to retrieve it. Decrypt using the account's KMS key.
- **Access Keys**: Both the key ID and secret are marked as sensitive. Store them securely (e.g., AWS Secrets Manager, HashiCorp Vault).
- **Best Practice**: Avoid creating access keys when possible. Use IAM roles for EC2, Lambda, and other AWS services instead.

### Force Destroy

Setting `force_destroy = true` allows Terraform to delete the user even if:
- Access keys exist
- Login profile exists
- MFA devices are attached

Use with caution in production environments.

### Group Memberships

Groups must exist before adding users to them. This module does not create groups.

## Common Use Cases

1. **Developer Access**: Console access with read-only or limited permissions
2. **CI/CD Users**: Programmatic access with deployment permissions
3. **Service Accounts**: API access with specific resource permissions
4. **CodeCommit Users**: SSH key access for Git operations
5. **Temporary Access**: Users with force_destroy enabled for easy cleanup
