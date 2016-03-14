defmodule IIIF.Presentation do
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
  defp filter_property({:sequences, _}), do: true
  defp filter_property({:canvases, _}), do: true
  defp filter_property({_, []}), do: false
  defp filter_property(_), do: true
end
