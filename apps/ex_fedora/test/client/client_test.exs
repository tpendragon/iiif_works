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

  test "failing to post", %{client: client} do
    {:error, _} = Client.post(client, random_string, :rdf_source, [])
  end

  test "HEAD request", %{client: client} do
    {:error, %{status_code: 404}} = Client.head(client, random_string)
  end

  test "PUT request", %{client: client} do
    str = random_string
    {:ok, _} = Client.put(client, str)
    {:ok, _} = Client.head(client, str)
  end

  def random_string do
    str_length = 8
    :crypto.strong_rand_bytes(str_length) |> Base.url_encode64 |> binary_part(0, str_length)
  end

  test "POST to create an object with metadata", %{client: client} do
    triples = %{
      "" => %{
        "http://test.com" => %RDF.Literal{value: "Testing", language: "en"},
        :_type_ => :predicate
      },
      :_type_ => :subject
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
