defmodule JsonApiClient.PaginationLinks do
  @moduledoc """
  JSON API JSON Pagination Links
  http://jsonapi.org/format/#fetching-pagination
  """

  defstruct self: nil, first: nil, prev: nil, next: nil, last: nil
end

defmodule JsonApiClient.Links do
  @moduledoc """
  JSON API JSON Links
  http://jsonapi.org/format/#document-links
  """

  defstruct self: nil, related: nil
end

defmodule JsonApiClient.ErrorLink do
  @moduledoc """
  JSON API JSON Error Object
  http://jsonapi.org/format/#errors
  """

  defstruct about: nil
end

defmodule JsonApiClient.Error do
  @moduledoc """
  JSON API JSON Error Object
  http://jsonapi.org/format/#errors
  """

  defstruct meta: nil
end

defmodule JsonApiClient.Relationships do
  @moduledoc """
  JSON API Relationships Object
  http://jsonapi.org/format/#document-resource-object-relationships
  """

  defstruct(
    data: nil,
    meta: nil,
  )

end

defmodule JsonApiClient.Resource do
  @moduledoc """
  JSON API Resource Object
  http://jsonapi.org/format/#document-resource-objects
  """

  alias JsonApiClient.{Links}

  defstruct(
    id:            nil,
    type:          nil,
    attributes:    nil,
    links:         nil,
    relationships: nil,
    meta:          nil,
  )
end

defmodule JsonApiClient.JsonApi do
  @moduledoc """
  JSON API JSON API Object
  http://jsonapi.org/format/#document-jsonapi-object
  """

  defstruct version: "1.0", meta: %{}
end

defmodule JsonApiClient.Document do
  @moduledoc """
  JSON API Document Object
  http://jsonapi.org/format/#document-structure
  """

  alias JsonApiClient.{Resource, JsonApi}

  defstruct(
    jsonapi: nil,
    data: nil,
    links: nil,
    meta: nil,
    included: nil,
    errors: nil
  )
end