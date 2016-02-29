defmodule NTriples do
  alias NTriples.Parser
  alias NTriples.Serializer
  def parse(content) do
    Parser.parse(content)
  end

  def serialize(map = %{}) do
    Serializer.serialize(map)
  end
end
