defmodule ApiClient.Notes do

  def all do
    case HTTPoison.get("http://localhost:3116/v1/assets") do
     {:ok, res} -> {:ok, Poison.decode!(res.body)["data"]}
     {:error, err} -> {:error, :service_unavailable}
    end
  end

end
