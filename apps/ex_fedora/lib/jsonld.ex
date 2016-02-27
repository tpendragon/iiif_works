require IEx
defmodule JSONLD do
  alias JSONLD.Parser
  def parse(content) do
    content
    |> Poison.decode!
    |> Parser.extract_statements
  end

end
