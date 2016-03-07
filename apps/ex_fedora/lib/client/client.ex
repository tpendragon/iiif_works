require IEx
defmodule ExFedora.Client do
  @moduledoc """
  Provides functions to post/get triples from a Fedora server.
  """

  alias ExFedora.RestClient
  alias ExFedora.Client.Response
  alias ExFedora.Client
  defstruct [:url, :transaction_id, root: ""]

  def post(client, id, type \\ :rdf_source, body \\ []) do
    {result, response} =
      client
      |> ensure_root
      |> id_to_url(id)
      |> RestClient.post(serialize_body(type, body), headers(type))
    process_response({result, response})
  end

  def start_transaction(client) do
    rootless_client = %{client | root: ""}
    {:ok, %{headers: %{location: location}}} = Client.post(rootless_client, "fcr:tx")
    %{client | transaction_id: uri_to_id(rootless_client, location)}
  end

  def rollback_transaction(client = %Client{transaction_id: id}) do
    rootless_client = %{client | root: ""}
    {result, response} = process_response(Client.post(rootless_client, "fcr:tx/fcr:rollback"))
    case result do
      :ok ->
        {:ok, %{client | transaction_id: nil}}
      _ ->
        {result, response}
    end
  end

  def commit_transaction(client = %Client{transaction_id: id}) do
    rootless_client = %{client | root: ""}
    {result, response} = process_response(Client.post(rootless_client, "fcr:tx/fcr:commit"))
    case result do
      :ok ->
        {:ok, %{client | transaction_id: nil}}
      _ ->
        {result, response}
    end
  end

  defp ensure_root(client = %ExFedora.Client{root: ""}), do: client
  defp ensure_root(client = %ExFedora.Client{root: binary}) do
    client
    |> put("")
    client
  end

  def id_to_url(client, ""), do: root_url(client)
  def id_to_url(client, "/" <> id), do: id_to_url(client, id)
  def id_to_url(client, id) do
    root_url(client) <> "/" <> id
  end

  def uri_to_id(client, uri) do
    leading_string = id_to_url(client, "")
    String.replace_leading(uri, leading_string <> "/" ,"")
  end

  defp root_url(client = %ExFedora.Client{transaction_id: transaction_id}) when is_binary(transaction_id) do
    new_url = client.url <> "/" <> transaction_id
    root_url(%Client{client | url: new_url, transaction_id: nil})
  end
  defp root_url(client = %ExFedora.Client{root: ""}), do: client.url
  defp root_url(client = %ExFedora.Client{root: binary}) when is_binary(binary) do
    client.url <> "/" <> client.root
  end

  def head(client, id) do
    result = 
      RestClient.head(
        id_to_url(client, id)
      )
    process_response(result)
  end

  def put(client, id, type \\ :rdf_source, body \\ []) do
    result = 
      RestClient.put(
        id_to_url(client, id),
        serialize_body(type, body),
        headers(type)
      )
    process_response(result)
  end

  def delete(client, id) do
    result = RestClient.delete(
      id_to_url(client, id)
    )
    process_response(result)
  end

  defp process_response({result, response}) do
    case {result, response} do
      {_, %{status_code: x}} when x >= 400 ->
        {:error, response}
      _ ->
        {result, response}
    end
  end

  defp serialize_body(:rdf_source, map = %{}) do
    NTriples.serialize(map)
  end

  defp serialize_body(:rdf_source, _body) do
    ""
  end

  defp serialize_body(_type, body) when is_binary(body) do
    body
  end

  defp headers(:rdf_source) do
    [
      "content-type": "text/turtle"
    ]
  end

  defp headers(_type) do
    []
  end

  def get(client, id) do
    {result, response} =
      id_to_url(client, id)
      |> RestClient.get
      |> process_response
    case result do
      :ok ->
        {result, parse_response(response)}
      _ ->
        {result, response}
    end
  end

  defp parse_response(response) do
    response
    |> Response.cast
    |> Response.parse_statements
  end

end
