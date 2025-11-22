# IAM Role Module - Variables

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "role_path" {
  description = "Path for the IAM role"
  type        = string
  default     = "/"
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) for the role"
  type        = number
  default     = 3600
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it"
  type        = bool
  default     = false
}

variable "custom_assume_role_policy" {
  description = "Custom assume role policy JSON. If provided, overrides trusted_services and trusted_role_arns"
  type        = string
  default     = null
}

variable "trusted_services" {
  description = "List of AWS service principals that can assume this role (e.g., ['ec2.amazonaws.com', 'lambda.amazonaws.com'])"
  type        = list(string)
  default     = []
}

variable "trusted_role_arns" {
  description = "List of AWS role ARNs that can assume this role"
  type        = list(string)
  default     = []
}

variable "assume_role_conditions" {
  description = "List of conditions for the assume role policy"
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = []
}

variable "require_mfa" {
  description = "Whether to require MFA for assuming the role (applies to IAM users/roles, not services)"
  type        = bool
  default     = false
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "custom_policies" {
  description = "Map of custom policies to create and attach to the role"
  type = map(object({
    name        = string
    description = string
    policy      = string
  }))
  default = {}
}

variable "inline_policies" {
  description = "List of inline policies to embed in the role"
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

variable "create_instance_profile" {
  description = "Whether to create an instance profile for EC2"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Name of the instance profile. Defaults to role_name if not specified"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
