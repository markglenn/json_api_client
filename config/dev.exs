use Mix.Config

config :json_api_client, 
  middlewares: [
    {JsonApiClient.Middleware.StatsLogger, log_level: :info},
    {JsonApiClient.Middleware.StatsTracker, wrap: {JsonApiClient.Middleware.DocumentParser, nil}},
    {JsonApiClient.Middleware.StatsTracker, wrap: {JsonApiClient.Middleware.HTTPClient, nil}},
  ]
