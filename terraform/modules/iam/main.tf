# IAM Module - Main Resources
# This module orchestrates IAM users, roles, and their relationships

# AWS Account Alias
resource "aws_iam_account_alias" "alias" {
  count = var.account_alias != null ? 1 : 0

  account_alias = var.account_alias
}

# IAM User - ecoutu (no direct permissions - must assume role)
module "user_ecoutu" {
  source = "../iam-user"

  user_name = var.user_name

  create_login_profile    = var.create_login_profile
  password_reset_required = var.password_reset_required
  create_access_key       = var.create_access_key

  # No direct managed policies - user must assume the admin role
  managed_policy_arns = []

  tags = var.tags
}

# IAM Role - Administrator Role
module "admin_role" {
  source = "../iam-role"

  role_name        = var.admin_role_name
  role_description = var.admin_role_description

  # Allow EC2 and other services to assume this role
  trusted_services = var.admin_role_trusted_services

  # Allow ecoutu user to assume this role
  trusted_role_arns = [
    module.user_ecoutu.user_arn
  ]

  # Require MFA for IAM users/roles to assume this role
  require_mfa = var.require_mfa

  # Attach AdministratorAccess policy for full superuser permissions
  managed_policy_arns = var.admin_role_managed_policies

  # Create instance profile for EC2 instances
  create_instance_profile = var.create_instance_profile

  # Allow up to 12 hours session duration
  max_session_duration = var.max_session_duration

  tags = merge(
    var.tags,
    {
      AccessLevel = "Administrator"
      Description = "Superuser role with full AWS access"
    }
  )
}

# IAM Policy to allow ecoutu user to assume the admin role (with MFA if required)
resource "aws_iam_policy" "user_assume_admin" {
  name        = "${var.user_name}-assume-admin-role"
  description = "Allow ${var.user_name} user to assume the admin role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = module.admin_role.role_arn
        Condition = var.require_mfa ? {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        } : {}
      }
    ]
  })

  tags = var.tags
}

# Attach the assume role policy to user
resource "aws_iam_user_policy_attachment" "user_assume_admin" {
  user       = module.user_ecoutu.user_name
  policy_arn = aws_iam_policy.user_assume_admin.arn
}

# IAM Policy to enforce MFA for all user actions (except MFA setup)
resource "aws_iam_policy" "enforce_mfa" {
  count = var.enforce_mfa_for_users ? 1 : 0

  name        = "${var.user_name}-enforce-mfa"
  description = "Deny all actions except MFA setup when MFA is not present"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyAllExceptListedIfNoMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken",
          "iam:GetAccountPasswordPolicy",
          "iam:GetAccountSummary",
          "iam:ListUsers",
          "iam:ChangePassword"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach MFA enforcement policy to user
resource "aws_iam_user_policy_attachment" "enforce_mfa" {
  count = var.enforce_mfa_for_users ? 1 : 0

  user       = module.user_ecoutu.user_name
  policy_arn = aws_iam_policy.enforce_mfa[0].arn
}

# IAM Policy for basic console self-service capabilities
resource "aws_iam_policy" "console_self_service" {
  name        = "${var.user_name}-console-self-service"
  description = "Allow ${var.user_name} user to manage own credentials and view account info"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ViewAccountInfo"
        Effect = "Allow"
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:GetAccountSummary",
          "iam:ListVirtualMFADevices"
        ]
        Resource = "*"
      },
      {
        Sid    = "ManageOwnUser"
        Effect = "Allow"
        Action = [
          "iam:GetUser",
          "iam:ListAccessKeys",
          "iam:ListSigningCertificates",
          "iam:ListSSHPublicKeys",
          "iam:ListServiceSpecificCredentials"
        ]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "ManageOwnPassword"
        Effect = "Allow"
        Action = [
          "iam:ChangePassword",
          "iam:GetLoginProfile"
        ]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "ManageOwnAccessKeys"
        Effect = "Allow"
        Action = [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:UpdateAccessKey",
          "iam:GetAccessKeyLastUsed"
        ]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "ManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:ListMFADevices",
          "iam:GetMFADevice"
        ]
        Resource = [
          "arn:aws:iam::*:user/$${aws:username}",
          "arn:aws:iam::*:mfa/$${aws:username}"
        ]
      },
      {
        Sid    = "DeactivateOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:DeactivateMFADevice",
          "iam:DeleteVirtualMFADevice"
        ]
        Resource = [
          "arn:aws:iam::*:user/$${aws:username}",
          "arn:aws:iam::*:mfa/$${aws:username}"
        ]
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach console self-service policy to user
resource "aws_iam_user_policy_attachment" "console_self_service" {
  user       = module.user_ecoutu.user_name
  policy_arn = aws_iam_policy.console_self_service.arn
}
