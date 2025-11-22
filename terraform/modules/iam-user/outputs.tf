# IAM User Module - Outputs

output "user_arn" {
  description = "ARN of the IAM user"
  value       = aws_iam_user.this.arn
}

output "user_name" {
  description = "Name of the IAM user"
  value       = aws_iam_user.this.name
}

output "user_unique_id" {
  description = "Unique ID assigned by AWS"
  value       = aws_iam_user.this.unique_id
}

output "login_profile_encrypted_password" {
  description = "Encrypted password for console login (only if login profile created)"
  value       = var.create_login_profile ? aws_iam_user_login_profile.this[0].encrypted_password : null
  sensitive   = true
}

output "access_key_id" {
  description = "Access key ID (only if access key created)"
  value       = var.create_access_key ? aws_iam_access_key.this[0].id : null
  sensitive   = true
}

output "access_key_secret" {
  description = "Access key secret (only if access key created)"
  value       = var.create_access_key ? aws_iam_access_key.this[0].secret : null
  sensitive   = true
}

output "access_key_status" {
  description = "Access key status (only if access key created)"
  value       = var.create_access_key ? aws_iam_access_key.this[0].status : null
}

output "ssh_key_id" {
  description = "SSH key ID (only if SSH key provided)"
  value       = var.ssh_public_key != null ? aws_iam_user_ssh_key.this[0].ssh_public_key_id : null
}

output "ssh_key_fingerprint" {
  description = "SSH key fingerprint (only if SSH key provided)"
  value       = var.ssh_public_key != null ? aws_iam_user_ssh_key.this[0].fingerprint : null
}

output "custom_policy_arns" {
  description = "ARNs of custom policies created"
  value       = { for k, v in aws_iam_policy.custom : k => v.arn }
}

output "custom_policy_ids" {
  description = "IDs of custom policies created"
  value       = { for k, v in aws_iam_policy.custom : k => v.id }
}
