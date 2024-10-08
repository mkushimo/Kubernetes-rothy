
#1. IAM users
resource "aws_iam_user" "eks_developers" {
  for_each      = toset(var.developers)
  name          = each.value
  force_destroy = true

  tags = {
    Department = "eks-developers"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_user" "eks_admins" {
  for_each      = toset(var.admins)
  name          = each.value
  force_destroy = true

  tags = {
    Department = "eks-admins"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

#2. IAM profiles
resource "aws_iam_user_login_profile" "DB_user" {
  for_each                = aws_iam_user.eks_developers
  user                    = each.value.name
  password_reset_required = true
  pgp_key                 = "keybase:kenmak"
}

resource "aws_iam_user_login_profile" "Admin_user" {
  for_each                = aws_iam_user.eks_admins
  user                    = each.value.name
  password_reset_required = true
  pgp_key                 = "keybase:kenmak"
}

#3.Developer's group
resource "aws_iam_group" "eks_developer" {
  name = "Developer"
}

resource "aws_iam_group_policy" "developer_policy" {
  name   = "developer"
  group  = aws_iam_group.eks_developer.name
  policy = data.aws_iam_policy_document.developer.json
}

resource "aws_iam_user_group_membership" "db_team" {
  for_each = aws_iam_user.eks_developers
  user     = each.value.name
  groups   = [aws_iam_group.eks_developer.name]
}

#4. Admins group
resource "aws_iam_group" "eks_masters" {
  name = "Masters"
}

resource "aws_iam_group_policy" "masters_policy" {
  name   = "masters"
  group  = aws_iam_group.eks_masters.name
  policy = data.aws_iam_policy_document.masters_role.json
}

resource "aws_iam_user_group_membership" "masters_team" {
  for_each = aws_iam_user.eks_admins
  user     = each.value.name
  groups   = [aws_iam_group.eks_masters.name]
}

#5. Password policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

# Admin role to be assumed only by admins
resource "aws_iam_role" "masters" {
  name               = "Masters-eks-Role"
  assume_role_policy = data.aws_iam_policy_document.masters_assume_role.json
}

resource "aws_iam_role_policy_attachment" "admin_policy" {
  role       = aws_iam_role.masters.name
  policy_arn = aws_iam_policy.eks_admin.arn
}

resource "aws_iam_policy" "eks_admin" {
  name   = "eks-masters"
  policy = data.aws_iam_policy_document.masters.json
}

