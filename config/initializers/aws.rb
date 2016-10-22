aws_config = {
  region: 'us-east-1',
  access_key_id: Rails.application.secrets.aws.fetch('access_key_id'),
  secret_access_key: Rails.application.secrets.aws.fetch('secret_access_key'),
}

Aws.config.update(aws_config)

AWS_LAMBDA_CLIENT = Aws::Lambda::Client.new(aws_config)
