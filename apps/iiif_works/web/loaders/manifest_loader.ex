require IEx
defmodule Iiif.Works.ManifestLoader do
  alias Iiif.Works.ManifestLoader.{FileSetLoader, WorkLoader, NullLoader}
  def from(work_node, url_generator, loader_finder \\ &loader/1)
  def from(work_node, url_generator, loader_finder) when is_function(loader_finder) do
    from(work_node, url_generator, loader_finder.(work_node))
  end
  def from(work = %{id: id}, url_generator, loader) do
    url = url_generator.(id)
    loader.generate()
    |> Map.put(:id, url)
    |> loader.load(work, url_generator)
    |> apply_view_data(work)
  end

  defp loader(members) when is_list(members) do
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
  defp loader(%{ordered_members: members}) do
    loader(members)
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
