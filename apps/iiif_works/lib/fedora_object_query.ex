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
      |> Enum.map(&Task.async(fn -> proxy_for(repo, work_node.__struct__, &1) end))
      |> Enum.map(&Task.await/1)
    Map.merge(work_node, %{ordered_members: ordered_members})
  end

  defp ordered_proxies(_, %{first: nil}), do: []
  defp ordered_proxies(repo, proxy = %Proxy{next: [%{"@id" => next_id}]}) do
    next_proxy = repo.get!(Proxy, url_to_id(repo, next_id))
    [proxy | ordered_proxies(repo, next_proxy)]
  end
  defp ordered_proxies(_, proxy = %Proxy{}), do: [proxy]
  defp ordered_proxies(repo, %{first: [%{"@id" => first_uri}]}) do
    proxy = repo.get!(Proxy, url_to_id(repo, first_uri))
    ordered_proxies(repo, proxy)
  end

  defp proxy_for(_, _, %{proxy_for: nil}), do: nil
  defp proxy_for(repo, work_node, %{proxy_for: [%{"@id" => proxy_for}]}) do
    repo.get!(work_node, url_to_id(repo, proxy_for))
  end

  defp url_to_id(repo, url) do
    ExFedora.Client.uri_to_id(Fedora.Ecto.client(repo), url)
  end
end
