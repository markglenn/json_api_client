defmodule JsonApiClient.Parsers.JsonApiProtocol do
  @moduledoc """
  Describes a JSON API Protocol
  """

  def index_document_object do
    index_document_fields = %{
      fields: %{
        data: %{
          array: true,
        },
        links: pagination_links_object()
      }
    }
    DeepMerge.deep_merge(document_object(), index_document_fields)
  end

  def show_document_object do
    show_document_fields = %{
      fields: %{
        links: links_object()
      }
    }
    DeepMerge.deep_merge(document_object(), show_document_fields)
  end

  def document_object do
    %{
      representation: JsonApiClient.Document,
      either_fields: ~w(data errors meta),
      fields: %{
        jsonapi: json_api_object(),
        data: resource_object(),
        meta: meta_object(),
        included: Map.put(resource_object(), :array, true),
        errors: Map.put(error_object(), :array, true)
      }
    }
  end

  def resource_object do
   %{
     representation: JsonApiClient.Resource,
     required_fields: ~w(type id),
     fields: %{
       type: nil,
       id: nil,
       attributes: %{
         representation: :object,
       }
     }
   }
  end

  def error_object do
   %{
      representation: JsonApiClient.Error,
      fields: %{
        id: nil,
        links: error_link_object(),
        status: nil,
        code: nil,
        title: nil,
        detail: nil,
        meta: meta_object(),
        source: error_source_object(),
      }
   }
  end

  def error_link_object  do
    %{
      representation: JsonApiClient.ErrorLink,
      fields: %{
        about: nil
      }
    }
  end

  def error_source_object  do
    %{
      representation: JsonApiClient.ErrorSource,
      either_fields: ~w(pointer parameter),
      fields: %{
        pointer: nil,
        parameter: nil
      }
    }
  end

  def json_api_object do
    %{
      representation: JsonApiClient.JsonApi,
      fields: %{
        meta: meta_object(),
        version: nil,
      }
    }
  end

  def links_object do
    %{
      representation: JsonApiClient.Links,
      fields: %{
        self: nil,
        related: nil
      }
    }
  end

  def pagination_links_object do
    %{
      representation: JsonApiClient.PaginationLinks,
      fields: %{
        self: nil,
        first: nil,
        prev: nil,
        next: nil,
        last: nil,
      }
    }
  end

  def relationships_object do
    %{
      representation: JsonApiClient.Relationships,
      either_fields: ~w(links data meta),
      fields: %{
        meta: %{
          representation: :object,
        },
        links: nil,
        version: nil,
      }
    }
  end

  def meta_object do
    %{
      representation: :object,
    }
  end
end


