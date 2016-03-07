require IEx
defmodule ExFedora.Client do
  @moduledoc """
  Provides functions to post/get triples from a Fedora server.
  """

  alias ExFedora.RestClient
  alias ExFedora.Client.Response
  defstruct [:url, root: ""]

  def post(client, id, type \\ :rdf_source, body \\ []) do
    {result, response} =
      RestClient.post(
        id_to_url(client, id),
        serialize_body(type, body),
        headers(type)
      )
    process_response({result, response})
  end

  def id_to_url(client, "") do
    root_url(client)
  end

  def id_to_url(client, "/" <> id) do
    id_to_url(client, id)
  end

  def id_to_url(client, id) do
    root_url(client) <> "/" <> id
  end

  defp root_url(client = %ExFedora.Client{root: ""}) do
    client.url
  end

  defp root_url(client = %ExFedora.Client{root: binary}) when is_binary(binary) do
    client.url <> "/" <> client.root
  end

  def head(client, id) do
    result = 
      RestClient.head(
        id_to_url(client, id)
      )
    process_response(result)
  end

  def put(client, id, type \\ :rdf_source, body \\ []) do
    result = 
      RestClient.put(
        id_to_url(client, id),
        serialize_body(type, body),
        headers(type)
      )
    process_response(result)
  end

  def delete(client, id) do
    result = RestClient.delete(
      id_to_url(client, id)
    )
    process_response(result)
  end

  defp process_response({result, response}) do
    case {result, response} do
      {_, %{status_code: x}} when x >= 400 ->
        {:error, response}
      _ ->
        {result, response}
    end
  end

  defp serialize_body(:rdf_source, map = %{}) do
    NTriples.serialize(map)
  end

  defp serialize_body(:rdf_source, _body) do
    ""
  end

  defp serialize_body(_type, body) when is_binary(body) do
    body
  end

  defp headers(:rdf_source) do
    [
      "content-type": "text/turtle"
    ]
  end

  defp headers(_type) do
    []
  end

  def get(client, id) do
    {result, response} =
      id_to_url(client, id)
      |> RestClient.get
      |> process_response
    case result do
      :ok ->
        {result, parse_response(response)}
      _ ->
        {result, response}
    end
  end

  defp parse_response(response) do
    response
    |> Response.cast
    |> Response.parse_statements
  end

end
