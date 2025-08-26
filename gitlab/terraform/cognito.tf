# --- Cognito users

resource "aws_cognito_user_pool" "gitlab-user-pool" {
  name = "gitlab-user-pool"
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = "1"
    }
    # recovery_mechanism {
    #   name     = "verified_phone_number"
    #   priority = "2"
    # }
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  # auto_verified_attributes = ["email", "phone_number"]
  auto_verified_attributes = ["email"]
  deletion_protection      = "INACTIVE"
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  mfa_configuration = "OFF"
  password_policy {
    minimum_length                   = "8"
    password_history_size            = "0"
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = "7"
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "phone_number"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "profile"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  sign_in_policy {
    allowed_first_auth_factors = ["PASSWORD"]
  }
  # sms_configuration {
  #   external_id    = "d161a3eb-0cb3-4467-8032-4485196c4734"
  #   sns_caller_arn = "arn:aws:iam::732457136693:role/service-role/CognitoIdpSNSServiceRole"
  #   sns_region     = "us-east-2"
  # }
  user_pool_tier      = "ESSENTIALS"
  username_attributes = ["email", "phone_number"]
  username_configuration {
    case_sensitive = false
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

# --- Cognito domain

resource "aws_cognito_user_pool_domain" "gitlab-domain" {
  domain       = "codebeneath-gitlab"
  user_pool_id = aws_cognito_user_pool.gitlab-user-pool.id
}

# --- Cognito app client

resource "aws_cognito_user_pool_client" "gitlab-app-client" {
  name                                          = "gitlab"
  generate_secret                               = true
  access_token_validity                         = "60"
  allowed_oauth_flows                           = ["code"]
  allowed_oauth_flows_user_pool_client          = true
  allowed_oauth_scopes                          = ["email", "openid", "phone", "profile"]
  auth_session_validity                         = "3"
  callback_urls                                 = ["https://gitlab.codebeneath-labs.org/users/auth/cognito/callback"]
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = true
  explicit_auth_flows                           = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_AUTH", "ALLOW_USER_SRP_AUTH"]
  id_token_validity                             = "60"
  prevent_user_existence_errors                 = "ENABLED"
  refresh_token_validity                        = "5"
  supported_identity_providers                  = ["COGNITO"]
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
  user_pool_id = aws_cognito_user_pool.gitlab-user-pool.id
}
