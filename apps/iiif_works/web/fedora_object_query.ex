require IEx
defmodule FedoraObjectQuery do
  def from_id(repo, work_node, id) do
    work_node
    |> repo.get!(id)
    |> preload_proxies(repo)
    |> extract_ordered_members(repo)
  end

  defp preload_proxies(work_node, repo) do
    proxies = 
      repo
      |> ordered_proxies(work_node)
      |> Enum.map(&Task.async(fn -> preload_proxy_for(repo, work_node.__struct__, &1) end))
      |> Enum.map(&Task.await/1)
    Map.put(work_node, :proxies, proxies)
  end

  defp extract_ordered_members(work_node = %{proxies: proxies}, repo) do
    ordered_members =
      proxies
      |> Enum.flat_map(fn(proxy) -> proxy.proxy_for end)
      |> Enum.map(fn(member) -> load_members(repo, work_node.__struct__, member) end)
    Map.put(work_node, :ordered_members, ordered_members)
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
        ExFedora.Model.from_graph(struct, next_id, graph)
        |> Map.put(:id, ExFedora.Client.uri_to_id(Fedora.Ecto.client(repo), next_id))
        |> Map.put(:uri, next_id)
        Process.put(cache_subject, graph)
        new_proxy
      graph ->
        ExFedora.Model.from_graph(struct, next_id, graph)
        |> Map.put(:id, ExFedora.Client.uri_to_id(Fedora.Ecto.client(repo), next_id))
        |> Map.put(:uri, next_id)
    end
  end

  defp preload_proxy_for(_, _, proxy = %{proxy_for: nil}), do: proxy
  defp preload_proxy_for(repo, work_node, proxy = %{proxy_for: [%{"@id" => proxy_for}]}) do
    result = repo.get!(work_node, url_to_id(repo, proxy_for))
    %{proxy | proxy_for: [result]}
  end

  defp load_members(_, _, r = %{members: nil}), do: r
  defp load_members(repo, work_node, r = %{members: members}) do
    members =
      members
      |> Enum.map(&Task.async(fn -> load_member(repo, work_node, &1) end))
      |> Enum.map(&Task.await/1)
    %{r | members: members}
  end
  defp load_member(repo, work_node, %{"@id" => uri}) do
    repo.get!(work_node, url_to_id(repo, uri))
  end

  defp url_to_id(repo, url) do
    ExFedora.Client.uri_to_id(Fedora.Ecto.client(repo), url)
  end
end
