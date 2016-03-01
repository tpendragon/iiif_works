defmodule ExFedora.Client.Response do
  @moduledoc """
  Provides a wrapper around a Fedora response, mostly to allow for RDF
  statements to be parsed from the response body.
  """
  defstruct [:body, :headers, :status_code, :statements]

  def cast(module) do
    Map.merge(%ExFedora.Client.Response{}, module)
  end

  def parse_statements(module) do
    %{module | statements: parse_graph(module.body,
      module.headers[:"content-type"]) }
  end

  defp parse_graph(body, "application/ld+json") do
    JSONLD.parse(body)
  end

  defp parse_graph(body, "application/n-triples") do
    NTriples.parse(body)
  end

  defp parse_graph(_body, _content_type) do
    []
  end
end
