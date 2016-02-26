defmodule ExFedora.Client.Response do
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

  defp parse_graph(body, content_type) do
    []
  end
end
