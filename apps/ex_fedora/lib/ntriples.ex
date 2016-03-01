defmodule NTriples do
  @moduledoc """
  Functions for parsing and serializing N-Triples into Maps.
  """
  alias NTriples.Parser
  alias NTriples.Serializer
  def parse(content) do
    Parser.parse(content)
  end

  def serialize(map = %{}) do
    Serializer.serialize(map)
  end
end
