# ExDecisivApiClient

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_decisiv_api_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_decisiv_api_client, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_decisiv_api_client](https://hexdocs.pm/ex_decisiv_api_client).

## Setup

### client name

Every request made to a service carries a special `User-Agent` header that looks like: `ExApiClient/0.1.0/client_name`. Each client is expected to set its `client_name` via:

```
config :ex_decisiv_api_client, client_name: "valentine"
```

### timeout

This library allows its users to specify a timeout for all its service calls by using a `timeout` setting. By default, the timeout is set to 500msecs.

```
config :ex_decisiv_api_client, timeout: 200
```

## How to use

### Notes

#### All
 To get a list of All Notes `ApiClient.Notes.all()`. You can pass different options to the all function to select specific fields, perform pagination, or sort by fields. See `api_client/notes.ex` for examples.
- Examples:
  - `ApiClient.Notes.all()`
  - `ApiClient.Notes.all(page: %{size: "5"})`
  - `ApiClient.Notes.all(fields: %{notes: "topic,recipients"})`
  - `ApiClient.Notes.all(page: %{size: "5", number: "2" }, sort="subject")`

#### Update
The Update function has an Update/2, which takes the UUID and the note data in which you want to update.
- Example:
  - `ApiClient.Notes.update(%{ "subject" => "updated subject"})`


#### Create
The create function accepts a map, that will be encoded to JSON.
- Example:
```
ApiClient.Notes.create(
  %{
    "topic" => "decisiv:notes:c9a37d6f-578f-42c2-bea7-dd3d456a7c13",
    "subject" => "test subject",
    "author" => "test author",
    "recipients" => ["decisiv:jskinner:6f698a0f-2e74-4273-987c-c781f2b44841"],
    "body" => "blah"
  })
```
