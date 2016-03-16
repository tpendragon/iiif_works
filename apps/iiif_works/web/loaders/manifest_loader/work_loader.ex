defmodule Iiif.Works.ManifestLoader.WorkLoader do
  alias IIIF.Presentation.Collection
  def load(manifest, %{ordered_members: members}, id_generator) when is_list(members) do
    manifests = members |> Enum.map(&build_manifest(&1, id_generator))
    manifest
    |> Map.put(:manifests, manifests)
  end

  def generate do
    %Collection{}
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
