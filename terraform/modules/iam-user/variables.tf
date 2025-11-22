# IAM User Module - Variables

variable "user_name" {
  description = "Name of the IAM user"
  type        = string
}

variable "user_path" {
  description = "Path for the IAM user"
  type        = string
  default     = "/"
}

variable "force_destroy" {
  description = "When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile, or MFA devices"
  type        = bool
  default     = false
}

variable "create_login_profile" {
  description = "Whether to create a login profile (console access) for the user"
  type        = bool
  default     = false
}

variable "password_reset_required" {
  description = "Whether the user should be forced to reset their password on first login"
  type        = bool
  default     = true
}

variable "create_access_key" {
  description = "Whether to create an access key for the user"
  type        = bool
  default     = false
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the user"
  type        = list(string)
  default     = []
}

variable "custom_policies" {
  description = "Map of custom policies to create and attach to the user"
  type = map(object({
    name        = string
    description = string
    policy      = string
  }))
  default = {}
}

variable "inline_policies" {
  description = "List of inline policies to embed in the user"
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "policy_path" {
  description = "Path for IAM policies"
  type        = string
  default     = "/"
}

variable "group_memberships" {
  description = "List of IAM group names to add the user to"
  type        = list(string)
  default     = []
}

variable "ssh_public_key" {
  description = "SSH public key for CodeCommit access"
  type        = string
  default     = null
}

variable "ssh_key_encoding" {
  description = "Encoding format for SSH public key (SSH or PEM)"
  type        = string
  default     = "SSH"
}

variable "ssh_key_status" {
  description = "Status of the SSH key (Active or Inactive)"
  type        = string
  default     = "Active"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
