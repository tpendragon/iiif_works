defmodule ExFedora.Client do
  @moduledoc """
  Provides functions to post/get triples from a Fedora server.
  """

  alias ExFedora.RestClient
  alias ExFedora.Client.Response
  defstruct [:url]

  def post(module, id, type \\ :rdf_source, body \\ []) do
    RestClient.post(
      module.url <> "/" <> id,
      serialize_body(type, body),
      headers(type)
    )
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
