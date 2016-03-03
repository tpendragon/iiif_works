require IEx
defmodule Fedora.Ecto do
  @behaviour Ecto.Adapter
  defmacro __before_compile__(env) do
    quote do
    end
  end

  def __pool__ do
    :fedora_ecto_pool
  end

  def client(repo) do
    %ExFedora.Client{url: Application.get_env(:ecto, repo)[:url]}
  end

  def child_spec(repo, opts) do
    poolboy_config = [
      {:name, {:local, __pool__}},
      {:worker_module, Fedora.Ecto.Connection},
      {:size, opts[:pool_size] || 1},
      {:max_overflow, 0}
    ]
    :poolboy.child_spec(__pool__, poolboy_config, [])
  end

  def autogenerate(:binary_id), do: nil

  def dumpers(_primitive, type) do
    [type]
  end

  def loaders(:literal, literal) do
    [&RDF.Literal.load/1, literal]
  end
  def loaders(_, type), do: [type]

  def insert(repo, schema_meta, fields, returning, options) do
    predicates = schema_meta.schema.__schema__(:predicates)
    transformed_graph = ExFedora.Model.to_graph(fields, predicates)
    combined_graph = RDF.Graph.merge(transformed_graph, fields[:unmapped_graph])
    {_, root} = schema_meta.source
    repo
    initialize(repo, root)
    pooled_command([client(repo), root, combined_graph])
    |> process_result(returning, client(repo))
  end

  defp pooled_command(args) do
    :poolboy.transaction(__pool__, 
      fn(pid) ->
        :gen_server.call(pid, args)
      end
    )
  end

  defp process_result({:ok, response}, returning, client) do
    output = 
      returning
      |> Enum.map(&process_result(&1, {response, client}))
    {:ok, output}
  end

  defp process_result(:id, {response, client}) do
    test_id = String.replace_leading(response.headers.location, client.url <> "/","")
    {:id, test_id}
  end

  defp initialize(repo, root) do
    pooled_command([client(repo), root])
    repo
  end
end
