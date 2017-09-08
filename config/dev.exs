use Mix.Config

# Load DynamoDB local
config :ex_aws, :dynamodb,
  access_key_id: "123",
  secret_access_key: "123",
  scheme: "http://",
  host: "localhost",
  port: 8000
