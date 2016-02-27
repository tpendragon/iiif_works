require IEx
defmodule JSONLD do
  alias JSONLD.Parser
  def parse(content) do
    poison_json = Poison.decode!(content)
    Enum.flat_map(poison_json, &Parser.extract_statements/1)
  end

end
