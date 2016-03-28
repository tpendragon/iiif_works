require IEx
defmodule Iiif.Works.ManifestLoader.PartLoader do
  alias IIIF.Presentation.{Sequence, Canvas, Manifest}
  import Iiif.Works.ManifestLoader, only: [label_or_title: 1]
  def load(%{id: work_id, ordered_members: members}, id_generator, image_loader, width_extractor \\ &works_width_height/2) when is_list(members) do
    id = id_generator.(work_id)
    canvases = members |> Enum.map(&build_canvas(&1, id, image_loader, width_extractor))
    sequence = %Sequence{} |> Map.put(:canvases, canvases)
    %Manifest{}
    |> Map.put(:sequences, [sequence])
  end

  defp build_canvas(fs = %{id: id}, work_id, image_loader, width_height_extractor) do
    %Canvas{}
    |> Map.put(:id, "#{work_id}/canvas/#{id}")
    |> Map.put(:label, label_or_title(fs))
    |> width_height_extractor.(fs)
    |> image_loader.(fs)
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
