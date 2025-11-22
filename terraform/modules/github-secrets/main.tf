terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.8.1"
    }
  }
}

provider "github" {
  token = var.github_token
}

# Parse repository owner and name from full repository name
locals {
  repo_parts = split("/", var.repository_name)
  repo_owner = local.repo_parts[0]
  repo_name  = local.repo_parts[1]
}

# Get repository information
data "github_repository" "this" {
  full_name = var.repository_name
}

# Set AWS_ROLE_TO_ASSUME secret for OIDC authentication
resource "github_actions_secret" "aws_role_to_assume" {
  repository      = data.github_repository.this.name
  secret_name     = "AWS_ROLE_TO_ASSUME"
  plaintext_value = var.aws_role_arn
}

# Set AWS_REGION as a repository variable (not secret since it's not sensitive)
resource "github_actions_variable" "aws_region" {
  repository    = data.github_repository.this.name
  variable_name = "AWS_REGION"
  value         = var.aws_region
}

# Set any additional secrets
resource "github_actions_secret" "additional" {
  for_each = nonsensitive(var.additional_secrets)

  repository      = data.github_repository.this.name
  secret_name     = each.key
  plaintext_value = each.value
}

# Set any additional variables
resource "github_actions_variable" "additional" {
  for_each = var.additional_variables

  repository    = data.github_repository.this.name
  variable_name = each.key
  value         = each.value
}
