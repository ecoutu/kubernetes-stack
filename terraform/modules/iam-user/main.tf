# IAM User Module - Main Resources

# IAM User
resource "aws_iam_user" "this" {
  name          = var.user_name
  path          = var.user_path
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name = var.user_name
    }
  )
}

# Login Profile (Console Access)
resource "aws_iam_user_login_profile" "this" {
  count = var.create_login_profile ? 1 : 0

  user                    = aws_iam_user.this.name
  password_reset_required = var.password_reset_required
}

# Access Keys
resource "aws_iam_access_key" "this" {
  count = var.create_access_key ? 1 : 0

  user = aws_iam_user.this.name
}

# Attach AWS Managed Policies
resource "aws_iam_user_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  user       = aws_iam_user.this.name
  policy_arn = each.value
}

# Create and attach custom policies
resource "aws_iam_policy" "custom" {
  for_each = var.custom_policies

  name        = each.value.name
  description = each.value.description
  policy      = each.value.policy
  path        = var.policy_path

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

resource "aws_iam_user_policy_attachment" "custom_policies" {
  for_each = aws_iam_policy.custom

  user       = aws_iam_user.this.name
  policy_arn = each.value.arn
}

# Inline Policies
resource "aws_iam_user_policy" "inline" {
  for_each = { for idx, policy in var.inline_policies : policy.name => policy }

  name   = each.value.name
  user   = aws_iam_user.this.name
  policy = each.value.policy
}

# Group Memberships
resource "aws_iam_user_group_membership" "this" {
  count = length(var.group_memberships) > 0 ? 1 : 0

  user   = aws_iam_user.this.name
  groups = var.group_memberships
}

# SSH Public Key (for CodeCommit)
resource "aws_iam_user_ssh_key" "this" {
  count = var.ssh_public_key != null ? 1 : 0

  username   = aws_iam_user.this.name
  encoding   = var.ssh_key_encoding
  public_key = var.ssh_public_key
  status     = var.ssh_key_status
}
