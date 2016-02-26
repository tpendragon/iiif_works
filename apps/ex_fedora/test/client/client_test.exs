require IEx
defmodule ExFedoraClientTest do
  use ExUnit.Case
  doctest ExFedora.Client
  alias ExFedora.Client

  setup do
    client = %Client{url: "http://localhost:8984/rest"}
    {:ok, client: client}
  end

  test "struct creation", %{client: client} do
    assert client.url == "http://localhost:8984/rest"
  end


  test "post to create RDF source", %{client: client} do
    {result, response} = Client.post(client, "", :rdf_source, [])
    assert response.status_code == 201
    assert response.headers.location
  end

  test "get an ID", %{client: client} do
    {_, %{headers: %{location: location}}} = Client.post(client, "")
    "http://localhost:8984/rest/" <> id = location
    {result, response} = Client.get(client, id)

    assert response.statements
    IEx.pry
    assert length(response.statements) == 1
  end
end
