require IEx
defmodule ExFedora.Client do
  @moduledoc """
  Provides functions to post/get triples from a Fedora server.
  """

  alias ExFedora.RestClient
  alias ExFedora.Client.Response
  defstruct [:url]

  def post(module, id, type \\ :rdf_source, body \\ []) do
    {result, response} =
      RestClient.post(
        module.url <> "/" <> id,
        serialize_body(type, body),
        headers(type)
      )
    process_response({result, response})
  end

  def head(module, id) do
    result = 
      RestClient.head(
        module.url <> "/" <> id
      )
    process_response(result)
  end

  def put(module, id, type \\ :rdf_source, body \\ []) do
    result = 
      RestClient.put(
        module.url <> "/" <> id,
        serialize_body(type, body),
        headers(type)
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

  def get(module, id) do
    {result, response} =
      module.url <> "/" <> id
      |> RestClient.get
    {result, parse_response(response)}
  end

  defp parse_response(response) do
    response
    |> Response.cast
    |> Response.parse_statements
  end

end
