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
  defp handle_id(id) when length(id) == 1 do
    case query_module do
      FedoraObjectQuery ->
        id |> expand_noid
      _ ->
        handle_id(Enum.at(id, 0))
    end
  end
  defp handle_id(id) when is_list(id), do: id |> Enum.join("/")

  defp load_manifest(conn, id) do
    Repo
    |> query_module.from_id(WorkNode, id)
    |> ManifestLoader.from(&manifest_url(conn, :show, String.split(compact_noid(&1), "/")))
  end

  defp query_module do
    FedoraObjectQuery
    # SolrWorksQuery
  end

  defp compact_noid(id) when is_binary(id) do
    compact_noid(String.split(id, "/"))
  end
  defp compact_noid(id) when is_list(id) do
    id
    |> Enum.at(-1)
  end
end
