variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "enable_versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption on the S3 bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
