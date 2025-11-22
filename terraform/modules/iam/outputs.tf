# IAM Module - Outputs

# User Outputs
output "user_arn" {
  description = "ARN of the IAM user"
  value       = module.user_ecoutu.user_arn
}

output "user_name" {
  description = "Name of the IAM user"
  value       = module.user_ecoutu.user_name
}

output "user_unique_id" {
  description = "Unique ID of the IAM user"
  value       = module.user_ecoutu.user_unique_id
}

output "user_access_key_id" {
  description = "Access key ID for the user"
  value       = module.user_ecoutu.access_key_id
  sensitive   = true
}

output "user_access_key_secret" {
  description = "Access key secret for the user"
  value       = module.user_ecoutu.access_key_secret
  sensitive   = true
}

# Admin Role Outputs
output "admin_role_arn" {
  description = "ARN of the administrator role"
  value       = module.admin_role.role_arn
}

output "admin_role_name" {
  description = "Name of the administrator role"
  value       = module.admin_role.role_name
}

output "admin_role_id" {
  description = "ID of the administrator role"
  value       = module.admin_role.role_id
}

output "admin_role_unique_id" {
  description = "Unique ID of the administrator role"
  value       = module.admin_role.role_unique_id
}

output "admin_instance_profile_arn" {
  description = "ARN of the admin role instance profile"
  value       = module.admin_role.instance_profile_arn
}

output "admin_instance_profile_name" {
  description = "Name of the admin role instance profile"
  value       = module.admin_role.instance_profile_name
}

# Policy Outputs
output "assume_role_policy_arn" {
  description = "ARN of the assume role policy"
  value       = aws_iam_policy.user_assume_admin.arn
}

output "console_self_service_policy_arn" {
  description = "ARN of the console self-service policy"
  value       = aws_iam_policy.console_self_service.arn
}

# Account Alias Output
output "account_alias" {
  description = "AWS account alias"
  value       = var.account_alias != null ? aws_iam_account_alias.alias[0].account_alias : null
}
