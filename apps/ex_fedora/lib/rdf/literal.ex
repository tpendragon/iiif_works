require IEx
defmodule RDF.Literal do
  @behaviour Ecto.Type
  defstruct [:value, :language]

  def cast(string) when is_binary(string) do
    {:ok, [string]}
  end
  def cast(%RDF.Literal{value: val, language: nil}) do
    { :ok, [val] }
  end
  def cast(%RDF.Literal{value: val, language: ""}) do
    { :ok, [val] }
  end
  def cast(literal = %RDF.Literal{}), do: { :ok, [literal] }
  def cast(literal = %{"@id" => _}), do: { :ok, [literal] }
  def cast(list) when is_list(list) do
    casted_list =
      list
      |> Enum.flat_map(fn(literal) -> elem({:ok, _} = cast(literal),1) end)
    {:ok, casted_list}
  end

  def load(literal = %RDF.Literal{}), do: { :ok, [literal] }
  def load(list) when is_list(list) do
    dumped_list =
      list
      |> Enum.flat_map(fn(literal) -> elem({:ok, _} = dump(literal),1) end)
    {:ok, dumped_list}
  end

  def dump(literal = %RDF.Literal{}), do: { :ok, [literal] }
  def dump(list) when is_list(list) do
    casted_list =
      list
      |> Enum.flat_map(fn(literal) -> elem({:ok, _} = dump(literal),1) end)
    {:ok, casted_list}
  end
  def dump(string) when is_binary(string) do
    {:ok, [%RDF.Literal{value: string}] }
  end
  def dump(id = %{"@id" => _}), do: {:ok, [id]}
  def dump(_), do: :error

  def type, do: :literal
end
