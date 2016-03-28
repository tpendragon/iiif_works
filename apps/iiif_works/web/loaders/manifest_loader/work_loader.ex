require IEx
defmodule Iiif.Works.ManifestLoader.WorkLoader do
  alias IIIF.Presentation.Collection
  alias Iiif.Works.ManifestLoader
  alias Iiif.Works.ManifestLoader.{PartLoader, ImageLoader}
  def load(work = %{ordered_members: members}, id_generator) when is_list(members) do
    child_members = Enum.flat_map(members, fn(member) -> member.members || [] end)
    ordered_member_types = ManifestLoader.types(child_members)
    load(Map.put(work, :child_members, child_members), ordered_member_types, id_generator)
  end
  defp load(work, [], id_generator), do: load(work, ["Work"], id_generator)
  defp load(%{ordered_members: members}, ["Work"], id_generator) do
    manifests = members |> Enum.map(&build_manifest(&1, id_generator))
    %Collection{}
    |> Map.put(:manifests, manifests)
  end
  defp load(work = %{child_members: child_members}, ["FileSet"], id_generator) do
    PartLoader.load(%{work | ordered_members: child_members}, id_generator, image_loader)
  end

  defp image_loader do
    &ImageLoader.load(&1, &2, IIIFPaths)
  end

  defp build_manifest(works, id_generator) when is_list(works) do
    works |> Enum.map(&build_manifest(&1, id_generator))
  end
  defp build_manifest(work = %{ordered_members: _}, id_generator) do
    work
    |> Iiif.Works.ManifestLoader.from(id_generator)
  end
  defp build_manifest(work, id_generator) do
    work
    |> Map.put(:ordered_members, [])
    |> build_manifest(id_generator)
  end
end
