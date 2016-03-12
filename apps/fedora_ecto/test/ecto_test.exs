defmodule RepoTest do
  use Ecto.Integration.Case
  alias Ecto.Integration.TestRepo
  import Ecto.Query, only: [from: 2]
  defmodule Book do
    use ExFedora.Schema
    schema "books" do
      property :title, predicate: "http://books.com"
    end
  end

  @tag timeout: 300000
  test "insert and get!" do
    graph = %{:_type_ => :subject, "" => %{:_type_ => :predicate,
      "http://predicate.com" => %RDF.Literal{value: "yo"}}}
    book = %Book{title: ["test"], unmapped_graph: graph}
    assert book.id == nil
    result = TestRepo.insert!(book)
    assert result.id
    assert result.uri

    new_result = TestRepo.get!(Book, result.id)
    assert new_result.id == result.id
    assert new_result.title == ["test"]
    assert new_result.uri == result.uri
    other_result = TestRepo.all(from(p in Book, where: p.id == ^new_result.id))
    assert other_result == [new_result]
    other_result = TestRepo.all(from(p in Book, where: p.uri == ^new_result.uri))
    assert other_result == [new_result]
  end

  test "record doesn't exist" do
    new_result = TestRepo.get(Book, "books/1")
    assert new_result == nil
  end

  test "deleting a record" do
    book = %Book{title: ["test"]}
    book = TestRepo.insert!(book)
    {:ok, _} = TestRepo.delete(book)
    assert TestRepo.get(Book, book.id) == nil
  end

  test "inserting language-tagged literals" do
    graph = %{:_type_ => :subject, "" => %{:_type_ => :predicate,
      "http://predicate.com" => %RDF.Literal{value: "yo", language: "en"}}}
    book = %Book{title: [%RDF.Literal{value: "testing", language: "en"}], unmapped_graph: graph}
    assert book.id == nil
    result = TestRepo.insert!(book)
    assert result.id

    new_result = TestRepo.get!(Book, result.id)
    assert new_result.id == result.id
    assert new_result.title == [%RDF.Literal{value: "testing", language: "en"}]

  end
end
