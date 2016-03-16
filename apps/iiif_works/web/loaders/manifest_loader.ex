require IEx
defmodule Iiif.Works.ManifestLoader do
  alias Iiif.Works.ManifestLoader.FileSetLoader
  alias Iiif.Works.ManifestLoader.WorkLoader
  alias Iiif.Works.ManifestLoader.NullLoader
  def from(work_node = %{ordered_members: members}, url_generator) do
    from(work_node, url_generator, loader(members))
    |> apply_view_data(work_node)
  end
  defp from(work = %{id: id}, url_generator, loader) do
    url = url_generator.(id)
    loader.generate()
    |> Map.put(:id, url)
    |> loader.load(work, url_generator)
  end

  defp loader(members) do
    case types(members) do
      ["FileSet"] ->
        FileSetLoader
      ["Work"] ->
        WorkLoader
      [] ->
        NullLoader
      _ ->
        nil
    end
  end

  defp apply_view_data(manifest = %{}, %{label: label, description: description}) do
    manifest
    |> Map.put(:label, label)
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
end
