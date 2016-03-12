defmodule RDF.URI do
  @behaviour Ecto.Type
  def cast(string) when is_binary(string) do
    {:ok, string}
  end
  def load(string), do: {:ok, string}

  def dump(string), do: {:ok, string}

  def type, do: :binary_id
end
