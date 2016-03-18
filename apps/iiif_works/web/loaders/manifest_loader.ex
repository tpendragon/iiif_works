require IEx
defmodule Iiif.Works.ManifestLoader do
  alias Iiif.Works.ManifestLoader.{FileSetLoader, WorkLoader, NullLoader, ImageLoader}
  def from(work = %{id: id}, url_generator, loader \\ &loader/2) do
    url = url_generator.(id)
    work
    |> loader.(url_generator)
    |> Map.put(:id, url)
    |> apply_view_data(work)
  end

  defp loader(members) when is_list(members) do
    case types(members) do
      ["FileSet"] ->
        &FileSetLoader.load(&1, &2, image_loader)
      ["Work"] ->
        &WorkLoader.load/2
      [] ->
        &NullLoader.load/2
      _ ->
        nil
    end
  end
  defp loader(work = %{ordered_members: members}, id_generator) do
    loader(members).(work, id_generator)
  end

  defp image_loader do
    &ImageLoader.load(&1, &2, IIIFPaths)
  end

  defp apply_view_data(manifest = %{}, work = %{description: description}) do
    manifest
    |> Map.put(:label, label_or_title(work))
    |> Map.put(:description, description)
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

  def label_or_title(%{label: label, title: title}) do
    label_or_title(label || title)
  end
  def label_or_title(nil), do: nil
  def label_or_title([label]), do: label
end
