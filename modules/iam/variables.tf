# IAM Module - Variables

variable "account_alias" {
  description = "AWS account alias for console sign-in URL"
  type        = string
  default     = null
}

variable "user_name" {
  description = "Name of the IAM user"
  type        = string
  default     = "ecoutu"
}

variable "create_login_profile" {
  description = "Whether to create console access for the user"
  type        = bool
  default     = true
}

variable "password_reset_required" {
  description = "Whether the user should reset password on first login"
  type        = bool
  default     = true
}

variable "create_access_key" {
  description = "Whether to create programmatic access key"
  type        = bool
  default     = true
}

variable "admin_role_name" {
  description = "Name of the admin role"
  type        = string
}

variable "admin_role_description" {
  description = "Description of the admin role"
  type        = string
  default     = "Administrator role with full superuser access"
}

variable "admin_role_trusted_services" {
  description = "List of AWS services that can assume the admin role"
  type        = list(string)
  default = [
    "ec2.amazonaws.com",
    "lambda.amazonaws.com",
    "ecs-tasks.amazonaws.com"
  ]
}

variable "admin_role_managed_policies" {
  description = "List of managed policies to attach to the admin role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

variable "create_instance_profile" {
  description = "Whether to create an instance profile for the admin role"
  type        = bool
  default     = true
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds for the admin role"
  type        = number
  default     = 43200
}

variable "require_mfa" {
  description = "Whether to require MFA for assuming the admin role"
  type        = bool
  default     = true
}

variable "enforce_mfa_for_users" {
  description = "Whether to enforce MFA for all user actions (denies actions without MFA except MFA setup)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all IAM resources"
  type        = map(string)
  default     = {}
}
