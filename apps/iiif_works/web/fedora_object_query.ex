require IEx
defmodule FedoraObjectQuery do
  def from_id(repo, work_node, id) do
    work_node
    |> repo.get!(id)
    |> load_ordered_members(repo)
  end

  defp load_ordered_members(work_node, repo) do
    ordered_members = 
      repo
      |> ordered_proxies(work_node)
      # |> Enum.map(&proxy_for(repo, work_node.__struct__, &1))
      |> Enum.map(&Task.async(fn -> proxy_for(repo, work_node.__struct__, &1) end))
      |> Enum.map(&Task.await/1)
    Map.merge(work_node, %{ordered_members: ordered_members})
  end

  defp ordered_proxies(_, %{first: nil}), do: []
  defp ordered_proxies(repo, proxy = %Proxy{next: [%{"@id" => next_id}]}) do
    next_proxy = cached_get(repo, Proxy, next_id)
    [proxy | ordered_proxies(repo, next_proxy)]
  end
  defp ordered_proxies(_, proxy = %Proxy{}), do: [proxy]
  defp ordered_proxies(repo, %{first: [%{"@id" => first_uri}]}) do
    proxy = cached_get(repo, Proxy, first_uri)
    ordered_proxies(repo, proxy)
  end

  defp cached_get(repo, struct, next_id) do
    cache_subject = next_id |> String.split("#") |> Enum.at(0)
    case Process.get(cache_subject) do
      nil ->
        {:ok, %{statements: graph}} = ExFedora.Client.get(Fedora.Ecto.client(repo), next_id)
        new_proxy = 
        ExFedora.Model.from_graph(Proxy, next_id, graph)
        |> Map.put(:id, ExFedora.Client.uri_to_id(Fedora.Ecto.client(repo), next_id))
        |> Map.put(:uri, next_id)
        Process.put(cache_subject, graph)
        new_proxy
      graph ->
        ExFedora.Model.from_graph(Proxy, next_id, graph)
        |> Map.put(:id, ExFedora.Client.uri_to_id(Fedora.Ecto.client(repo), next_id))
        |> Map.put(:uri, next_id)
    end
  end

  defp proxy_for(_, _, %{proxy_for: nil}), do: nil
  defp proxy_for(repo, work_node, %{proxy_for: [%{"@id" => proxy_for}]}) do
    repo.get!(work_node, url_to_id(repo, proxy_for))
  end

  defp url_to_id(repo, url) do
    ExFedora.Client.uri_to_id(Fedora.Ecto.client(repo), url)
  end
end
