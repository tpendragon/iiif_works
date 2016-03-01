defmodule ExFedora.RestClient do
  @moduledoc """
  HTTPoison-based REST Client for accessing a Fedora Endpoint. Sends
  RDF-specific accept headers.
  """
  use HTTPoison.Base
  defp process_headers(headers) do
    headers
    |> Enum.map(&process_header/1)
    |> Enum.reduce(%{}, &tuple_to_map/2)
  end

  defp process_header(headers) do
    headers
  end

  defp process_request_headers(headers) when is_map(headers) do
    Enum.into(headers, [{"Accept", "application/n-triples,
        application/octet-stream"}])
  end

  defp process_request_headers(headers) do
    Enum.into(headers, [{"Accept", "application/n-triples, 
        application/octet-stream"}])
  end

  defp tuple_to_map({key, values}, map) do
    Map.put(map, header_atom(key), values)
  end

  defp header_atom(header_string) do
    header_string
    |> String.downcase
    |> String.to_atom
  end
end
