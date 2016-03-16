defmodule Iiif.Works.ManifestLoader.FileSetLoader do
  alias IIIF.Presentation.Collection
  alias IIIF.Presentation.Manifest
  alias IIIF.Presentation.Sequence
  alias IIIF.Presentation.Canvas
  def load(manifest = %{id: id}, %{ordered_members: members}, _) when is_list(members) do
    canvases = members |> Enum.map(&build_canvas(&1, id))
    sequence = %Sequence{} |> Map.put(:canvases, canvases)
    manifest
    |> Map.put(:sequences, [sequence])
  end

  def generate do
    %Manifest{}
  end

  defp build_canvas(fs = %{height: height, width: width, id: id}, work_id) do
    %Canvas{}
    |> Map.put(:id, "#{work_id}/canvas/#{id}")
    |> Map.put(:height, height)
    |> Map.put(:width, width)
    |> Map.put(:label, fs.label)
  end
end
