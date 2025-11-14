# IAM Module

This module manages IAM resources including users, roles, and their relationships. It creates a user with console and programmatic access that must assume an admin role to perform AWS operations.

## Features

- IAM user with console and programmatic access
- Administrator role with full AWS access
- Assume role permissions for the user
- Console self-service capabilities (password, MFA, access keys)
- Instance profile for EC2 usage
- Cross-account and service trust policies

## Architecture

The module creates a secure IAM setup where:
1. User has minimal direct permissions (only self-service)
2. User must assume an admin role to access AWS resources
3. Admin role can be assumed by the user and AWS services
4. MFA can be enforced for both role assumption and all user actions
5. All actions are auditable through CloudTrail

## Usage

```hcl
module "iam" {
  source = "./modules/iam"

  user_name       = "john.doe"
  admin_role_name = "dev-admin-role"

  create_login_profile    = true
  password_reset_required = true
  create_access_key       = true

  admin_role_trusted_services = [
    "ec2.amazonaws.com",
    "lambda.amazonaws.com"
  ]

  create_instance_profile = true
  max_session_duration    = 43200

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| user_name | Name of the IAM user | string | "ecoutu" | no |
| create_login_profile | Create console access | bool | true | no |
| password_reset_required | Require password reset | bool | true | no |
| create_access_key | Create access key | bool | true | no |
| admin_role_name | Name of the admin role | string | - | yes |
| admin_role_description | Description of admin role | string | "Administrator role..." | no |
| admin_role_trusted_services | AWS services that can assume role | list(string) | [ec2, lambda, ecs] | no |
| admin_role_managed_policies | Managed policies for admin role | list(string) | [AdministratorAccess] | no |
| create_instance_profile | Create EC2 instance profile | bool | true | no |
| max_session_duration | Max session duration in seconds | number | 43200 | no |
| require_mfa | Require MFA for assuming admin role | bool | true | no |
| enforce_mfa_for_users | Enforce MFA for all user actions | bool | true | no |
| tags | Tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| user_arn | ARN of the IAM user |
| user_name | Name of the IAM user |
| user_access_key_id | Access key ID (sensitive) |
| user_access_key_secret | Access key secret (sensitive) |
| admin_role_arn | ARN of the admin role |
| admin_role_name | Name of the admin role |
| admin_instance_profile_arn | Instance profile ARN |
| assume_role_policy_arn | Assume role policy ARN |
| console_self_service_policy_arn | Self-service policy ARN |

## Security Features

### User Permissions
- No direct resource access
- Can only manage own credentials
- Must assume role for AWS operations

### Console Self-Service
- View account information
- Change own password
- Manage own access keys
- Enable/disable MFA
- View/manage SSH keys

### Role Assumption
- User can assume admin role
- AWS services can assume admin role
- 12-hour session duration
- Full audit trail in CloudTrail

### MFA Enforcement
- **require_mfa**: Requires MFA to assume the admin role
- **enforce_mfa_for_users**: Denies all user actions without MFA (except MFA setup and login)
- Users can still set up MFA devices without having MFA enabled
- After MFA is enabled, users must authenticate with MFA for all operations

## Best Practices

1. **MFA**: Enable MFA enforcement for all users (default: enabled)
2. **Key Rotation**: Rotate access keys regularly
3. **Least Privilege**: Customize admin role policies if full admin access isn't needed
4. **Monitoring**: Monitor AssumeRole events in CloudTrail
5. **Session Duration**: Adjust based on security requirements
6. **MFA Setup**: Users should set up MFA immediately after receiving credentials
