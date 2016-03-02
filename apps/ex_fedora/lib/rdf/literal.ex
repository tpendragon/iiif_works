defmodule RDF.Literal do
  @behaviour Ecto.Type
  defstruct [:value, :language]

  def cast(string) when is_binary(string) do
    {:ok, %RDF.Literal{value: string}}
  end
  def cast(literal = %RDF.Literal{}), do: { :ok, literal }

  def load(literal = %RDF.Literal{}), do: { :ok, literal }
  
  def dump(literal = %RDF.Literal{}), do: { :ok, literal }
  def dump(_), do: :error

  def type, do: :literal
end
