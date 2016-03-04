require IEx
defmodule Fedora.Ecto.Connection do
  use GenServer

  def start_link([]) do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call([:insert, client, root, graph], pid, state) do
    result = ExFedora.Client.post(client, root, :rdf_source, graph)
    {:reply, result, state}
  end

  def handle_call([:put, client, root], pid, state) do
    result = ExFedora.Client.put(client, root)
    {:reply, result, state}
  end

  def handle_call([:query, client, params], pid, state) when is_binary(params) do
    result = ExFedora.Client.get(client, params)
    {:reply, result, state}
  end

  def handle_call([:query, client, params], pid, state) when is_list(params) do
    handle_call([:query, client, List.first(params)], pid, state)
  end
end
