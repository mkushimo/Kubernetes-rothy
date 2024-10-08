/*
output "password" {
  value = [aws_iam_user_login_profile.DB_user.encrypted_password]
  #terraform output password | base64 --decode | keybase pgp decrypt
}

output "admin_password" {
  value = [aws_iam_user_login_profile.Admin_user.encrypted_password]
  #terraform output password | base64 --decode | keybase pgp decrypt
}
*/