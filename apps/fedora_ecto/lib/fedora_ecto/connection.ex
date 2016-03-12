require IEx
defmodule Fedora.Ecto.Connection do
  use GenServer

  def start_link([]) do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call([:insert, client, root, graph], _pid, state) do
    result = ExFedora.Client.post(client, root, :rdf_source, graph)
    {:reply, result, state}
  end

  def handle_call([:put, client, root], _pid, state) do
    result = ExFedora.Client.put(client, root)
    {:reply, result, state}
  end

  def handle_call([:query, client, %{ wheres: [%{expr: {:==, _, [{{_, _, [_,
                    :id]}, _, _}, _]}}]}, params], _pid, state) when is_binary(params) do
    run_query(client, params, state)
  end

  def handle_call([:query, client, %{ wheres: [%{expr: {:==, _, [{{_, _, [_,
                    :uri]}, _, _}, _]}}]}, params], _pid, state) when is_binary(params) do
    id = ExFedora.Client.uri_to_id(client, params)
    run_query(client, id, state)
  end

  defp run_query(client, id, state) do
    result = ExFedora.Client.get(client, id)
    {:reply, result, state}
  end

  def handle_call([:query, client, query, params], pid, state) when is_list(params) do
    handle_call([:query, client, query, List.first(params)], pid, state)
  end

  def handle_call([:delete, client, id], pid, state) do
    result = ExFedora.Client.delete(client, id)
    {:reply, result, state}
  end
end
