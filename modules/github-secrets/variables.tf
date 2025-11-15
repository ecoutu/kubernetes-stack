variable "github_token" {
  description = "GitHub personal access token with repo permissions"
  type        = string
  sensitive   = true
}

variable "repository_name" {
  description = "Full repository name (e.g., 'owner/repo')"
  type        = string
}

variable "aws_role_arn" {
  description = "ARN of the AWS IAM role to assume"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the workflow"
  type        = string
  default     = "us-east-1"
}

variable "additional_secrets" {
  description = "Additional secrets to set in the repository"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "additional_variables" {
  description = "Additional variables to set in the repository"
  type        = map(string)
  default     = {}
}
