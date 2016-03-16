defmodule Iiif.Works.ManifestLoader.FileSetLoader do
  alias IIIF.Presentation.{Sequence, Canvas, Manifest}
  def load(%{id: work_id, ordered_members: members}, id_generator) when is_list(members) do
    id = id_generator.(work_id)
    canvases = members |> Enum.map(&build_canvas(&1, id))
    sequence = %Sequence{} |> Map.put(:canvases, canvases)
    %Manifest{}
    |> Map.put(:sequences, [sequence])
  end

  defp build_canvas(fs = %{height: height, width: width, id: id}, work_id) do
    %Canvas{}
    |> Map.put(:id, "#{work_id}/canvas/#{id}")
    |> Map.put(:height, height)
    |> Map.put(:width, width)
    |> Map.put(:label, fs.label)
  end
end
