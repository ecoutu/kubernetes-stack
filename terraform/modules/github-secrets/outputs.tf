output "repository_name" {
  description = "Name of the GitHub repository"
  value       = data.github_repository.this.name
}

output "repository_full_name" {
  description = "Full name of the GitHub repository"
  value       = data.github_repository.this.full_name
}

output "secrets_configured" {
  description = "List of secrets that were configured"
  value = concat(
    ["AWS_ROLE_TO_ASSUME"],
    keys(var.additional_secrets)
  )
}

output "variables_configured" {
  description = "List of variables that were configured"
  value = concat(
    ["AWS_REGION"],
    keys(var.additional_variables)
  )
}

output "aws_role_arn" {
  description = "The AWS role ARN that was configured"
  value       = var.aws_role_arn
}
