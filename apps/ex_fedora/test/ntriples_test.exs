require IEx
defmodule NTriplesTest do
  use ExUnit.Case, async: true
  doctest NTriples
  alias RDF.Literal

  test "parsing a single n-triple" do
    {:ok, content} = File.read("test/fixtures/single_ntriple.nt")
    result = NTriples.parse(content)
    assert result["http://test.com"]["http://predicate.com"] == %Literal{value:
      "Fred's Phone", language: "en"}
  end

  test "parsing multiple n-triples" do
    {:ok, content} = File.read("test/fixtures/multiple_ntriple.nt")
    result = NTriples.parse(content)
    assert result["http://test.com"]["http://predicate.com"] == [%Literal{value:
      "Fred's Third Phone", language: "en"}, %Literal{value: "Fred's Phone",
      language: "en"}, %Literal{value: "Fred's Other Phone",
      language: "en"}]
    assert result["http://test.com"]["http://predicate.com/2"] == %Literal{value:
      "Fred's Tablet", language: "en"}
    assert result["http://test.com/2"]["http://predicate.com"] == %Literal{value:
      "Fred's Stuff", language: "en"}
    assert result["http://test.com/3"]["http://predicate.com"] == %{"@id" =>
      "http://mystuff.com" }  end
end
