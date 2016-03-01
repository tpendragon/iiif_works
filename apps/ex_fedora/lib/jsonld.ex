defmodule JSONLD do
  @moduledoc """
  Functions for parsing and serializing JSON-LD graphs.
  """
  alias JSONLD.Parser
  def parse(content) do
    content
    |> Poison.decode!
    |> Parser.extract_statements
  end

end
