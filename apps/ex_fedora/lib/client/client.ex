defmodule ExFedora.Client do
  alias ExFedora.RestClient
  alias ExFedora.Client.Response
  defstruct [:url]

  def post(module, id, type \\ :rdf_source, body \\ []) do
    RestClient.post(Path.join(module.url, id), parse_body(type, body), headers(type))
  end

  defp parse_body(:rdf_source, _body) do
    ""
  end

  defp parse_body(_type, body) do
    body
  end

  defp headers(:rdf_source) do
    [
      "content-type": "application/n-triples"
    ]
  end

  defp headers(_type) do
    []
  end

  def get(module, id) do
    {result, response} = 
      module.url
      |> Path.join(id)
      |> RestClient.get
    response = 
      response
      |> Response.cast
      |> Response.parse_statements
    {result, response}
  end

end
