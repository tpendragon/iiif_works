defmodule Iiif.Works.ManifestLoader.FileSetLoader do
  alias IIIF.Presentation.{Sequence, Canvas, Manifest}
  def load(%{id: work_id, ordered_members: members}, id_generator,
  width_extractor \\ &works_width_height/2) when is_list(members) do
    id = id_generator.(work_id)
    canvases = members |> Enum.map(&build_canvas(&1, id, width_extractor))
    sequence = %Sequence{} |> Map.put(:canvases, canvases)
    %Manifest{}
    |> Map.put(:sequences, [sequence])
  end

  defp build_canvas(fs = %{height: height, width: width, id: id}, work_id, width_height_extractor) do
    %Canvas{}
    |> Map.put(:id, "#{work_id}/canvas/#{id}")
    |> Map.put(:label, fs.label)
    |> width_height_extractor.(fs)
  end

  defp works_width_height(canvas, %{height: height, width: width}) do
    height = extract_int(height)
    width = extract_int(width)
    canvas
    |> Map.put(:width, width)
    |> Map.put(:height, height)
  end

  defp extract_int(int) when is_integer(int), do: int
  defp extract_int(int) when is_binary(int), do: elem(Integer.parse(int),0)
  defp extract_int([int]), do: extract_int(int)
end
