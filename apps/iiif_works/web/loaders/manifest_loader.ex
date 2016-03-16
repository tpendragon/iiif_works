require IEx
defmodule Iiif.Works.ManifestLoader do
  alias IIIF.Presentation.Manifest
  alias IIIF.Presentation.Sequence
  alias IIIF.Presentation.Canvas
  def from(work_node = %{ordered_members: members}, url_generator) do
    from(work_node, types(members), url_generator)
  end
  # Only file sets - generate canvases
  defp from(%{ordered_members: members, id: id}, ["FileSet"], url_generator) do
    url = url_generator.(id)
    %Manifest{}
    |> Map.put(:id, url)
    |> Map.put(:sequences, [from_fileset(members, url)])
  end


  defp from_fileset(canvases, id) when is_list(canvases) do
    canvases = canvases |> Enum.map(&from_fileset(&1, id))
    %Sequence{}
    |> Map.put(:canvases, canvases)
  end
  defp from_fileset(fs = %{height: height, width: width, id: id}, work_id) do
    %Canvas{}
    |> Map.put(:id, "#{work_id}/canvas/#{id}")
    |> Map.put(:height, height)
    |> Map.put(:width, width)
    |> Map.put(:label, fs.label)
  end


  def types(members) when is_list(members) do
    members
    |> Enum.flat_map(fn(x) -> x.type end)
    |> Enum.uniq
    |> Enum.map(fn(x) -> x["@id"] end)
    |> Enum.map(&strip_works_namespace/1)
    |> Enum.filter(&work_type?/1)
  end

  defp strip_works_namespace(uri) do
    uri
    |> String.replace_leading("http://pcdm.org/works#","")
    |> String.replace_leading("http://projecthydra.org/works/models#","")
  end

  defp work_type?(type) do
    case type do
      "FileSet" ->
        true
      "Work" ->
        true
      "Collection" ->
        true
      "Range" ->
        true
      "TopRange" ->
        true
      _ ->
        false
    end
  end
end
