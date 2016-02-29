require IEx
defmodule ExFedoraClientTest do
  use ExUnit.Case, async: true
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
    {_, response} = Client.post(client, "", :rdf_source, [])
    assert response.status_code == 201
    assert response.headers.location
  end

  test "POST to create an object with metadata", %{client: client} do
    triples = %{
      "" => %{
        "http://test.com" => %RDF.Literal{value: "Testing", language: "en"}
      }
    }
    {_, response} = Client.post(client, "", :rdf_source, triples)
    assert response.status_code == 201
    %{headers: %{location: location}} = response
    "http://localhost:8984/rest/" <> id = location
    {_, response} = Client.get(client, id)

    assert response.statements
    assert response.statements[location]["http://test.com"] ==
    %RDF.Literal{value: "Testing", language: "en"}
  end

  test "get an ID", %{client: client} do
    {_, %{headers: %{location: location}}} = Client.post(client, "")
    "http://localhost:8984/rest/" <> id = location
    {_, response} = Client.get(client, id)

    assert response.statements
    assert RDF.Graph.size(response.statements) == 13
  end
end
