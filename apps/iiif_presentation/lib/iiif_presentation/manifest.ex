defmodule IIIF.Presentation.Manifest do
  @default_context "http://iiif.io/api/presentation/2/context.json"
  @rdf_type "sc:Manifest"
  defstruct id: nil, canvases: [], context: @default_context, type: @rdf_type,
            label: nil, metadata: [], description: nil, thumbnail: nil,
            viewingHint: nil, viewingDirection:  nil, navDate: nil,
            license: nil, attribution: nil, logo: nil, related: nil,
            service: nil, seeAlso: nil, rendering: nil, within: nil,
            sequences: []

  def valid?(manifest) do
    cond do
      !manifest.label ->
        false
      !manifest.id ->
        false
      !manifest.type ->
        false
      true ->
        true
    end
  end

  def to_json(manifest) do
    manifest
    |> Map.from_struct
    |> Enum.map(&set_property/1)
    |> Enum.filter(&filter_property/1)
    |> Enum.into(%{})
  end

  defp set_property({:context, value}), do: {"@context", value}
  defp set_property({:id, value}), do: {"@id", value}
  defp set_property({:type, value}), do: {"@type", value}
  defp set_property({_, nil}), do: nil
  defp set_property(tuple), do: tuple

  defp filter_property(nil), do: false
  defp filter_property({_, []}), do: false
  defp filter_property(_), do: true
end
