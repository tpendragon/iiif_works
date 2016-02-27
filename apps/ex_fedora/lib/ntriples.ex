defmodule NTriples do
  alias NTriples.Parser
  def parse(content) do
    Parser.parse(content)
  end
end
