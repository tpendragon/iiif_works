defmodule ManifestConverter do
  def from_work(work, id_to_manifest_path) do
    manifest = %IIIF.Presentation.Manifest{id: id_to_manifest_path.(work.id)}
    manifest = %{manifest | canvases: canvases(work, id: manifest.id)}
  end

  defp canvases(%{ordered_members: []}, _), do: []
  defp canvases(%{ordered_members: ordered_members}, id: id) do
    ordered_members
    |> Enum.filter(&file_set?/1)
    |> Enum.map(&build_canvas(&1, id))
  end

  defp file_set?(type) when is_binary(type) do
    case type do
      "http://pcdm.org/works/models#FileSet" ->
        true
      "http://projecthydra.org/works/models#FileSet" ->
        true
      _ ->
        false
    end
  end
  defp file_set?(file_set) do
    file_set.type
    |> Enum.any?(fn(%{"@id" => type}) -> file_set?(type) end)
  end

  defp build_canvas(file_set, id) do
    %{
      "@id" => "#{id}/canvases/#{file_set.id}",
      "@type" => "sc:Canvas"
    }
  end
end
