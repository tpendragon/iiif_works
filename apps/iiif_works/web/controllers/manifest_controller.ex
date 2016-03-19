require IEx
defmodule IiifWorks.ManifestController do
  use IiifWorks.Web, :controller
  alias Iiif.Works.ManifestLoader
  plug :handle_id

  def show(conn, %{"id" => id}) when is_binary(id) do
    manifest = load_manifest(conn, id)
    render conn, "show.json", data: manifest
  end

  defp expand_noid([id]) do
    expanded_id = 
      id
      |> String.to_char_list
      |> Enum.chunk(2)
      |> Enum.slice(0..3)
      |> Enum.join("/")
    "#{expanded_id}/#{id}"
  end

  defp handle_id(conn = %{params: %{"id" => id}}, _) do
    %{conn | params: put_in(conn.params, ["id"], handle_id(id))}
  end
  defp handle_id(conn, _), do: conn
  defp handle_id(id) when is_binary(id), do: id
  defp handle_id(id) when length(id) == 1, do: Enum.at(id, 0)
  defp handle_id(id) when is_list(id), do: id |> Enum.join("/")

  defp load_manifest(conn, id) do
    WorkNode
    |> SolrWorksQuery.from_id(id)
    |> ManifestLoader.from(&manifest_url(conn, :show, String.split(compact_noid(&1), "/")))
  end

  defp compact_noid(id) when is_binary(id) do
    compact_noid(String.split(id, "/"))
  end
  defp compact_noid(id) when is_list(id) do
    id
    |> Enum.at(-1)
  end
end
