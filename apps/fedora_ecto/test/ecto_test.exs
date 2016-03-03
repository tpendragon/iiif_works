require IEx
defmodule RepoTest do
  use Ecto.Integration.Case
  alias Ecto.Integration.TestRepo
  defmodule Book do
    use ExFedora.Schema
    schema "books" do
      property :title, predicate: "http://books.com"
    end
  end

  test "insert and get!" do
    graph = %{:_type_ => :subject, "" => %{:_type_ => :predicate,
      "http://predicate.com" => %RDF.Literal{value: "yo"}}}
    book = %Book{title: ["test"], unmapped_graph: graph}
    assert book.id == nil
    result = TestRepo.insert!(book)
    assert result.id
    IO.puts result.id
  end
end
