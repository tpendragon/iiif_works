require IEx
defmodule Fedora.Ecto do
  @behaviour Ecto.Adapter
  alias Fedora.Ecto.NormalizedQuery
  defmacro __before_compile__(env) do
    quote do
    end
  end

  def __pool__ do
    :fedora_ecto_pool
  end

  def client(repo) do
    %ExFedora.Client{url:
      "http://#{repo.config[:hostname]}:#{repo.config[:port]}/#{repo.config[:database]}", root:
      repo.config[:ldp_root]}
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
    pooled_command([:insert, client(repo), root, combined_graph])
    |> process_result(returning, client(repo))
  end

  def prepare(function, query) do
    {:nocache, {function, query}}
  end

  def execute(repo, meta, {cached, {:all, query}}, params, preprocess, opts) do
    client = client(repo)
    {root, struct} = query.from
    params = List.first(params)
    result = pooled_command([:query, client, params])
    case result do
      {:ok, output} ->
        subject = ExFedora.Client.id_to_url(client, params)
        result = ExFedora.Model.from_graph(struct, subject, output.statements)
        result = Map.put(result, :id, String.replace_leading(result.id,
        ExFedora.Client.id_to_url(client, "") <> "/", ""))
        {1, [[result]]}
      {:error, %{status_code: 404}} ->
        {0, []}
      {:error, %{status_code: 410}} ->
        {0, []}
      {:error, _} ->
        raise "Something went wrong when querying for #{params}"
    end
  end

  def delete(repo, schema_meta, filters, options) do
    client = client(repo)
    [id: id] = filters
    result = pooled_command([:delete, client, id])
    case result do
      {:ok, _} ->
        {:ok, filters}
      {:error, _} ->
        {:error, :stale}
    end
  end

  defp pooled_command(args) do
    :poolboy.transaction(__pool__, 
      fn(pid) ->
        :gen_server.call(pid, args)
      end,
      :infinity
    )
  end

  defp process_result({:ok, response}, returning, client) do
    output = 
      returning
      |> Enum.map(&process_result(&1, {response, client}))
    {:ok, output}
  end

  defp process_result(:id, {response, client}) do
    test_id = String.replace_leading(response.headers.location,
    ExFedora.Client.id_to_url(client, "") <> "/","")
    {:id, test_id}
  end

  defp initialize(repo, root) do
    pooled_command([:put, client(repo), root])
    repo
  end
end
