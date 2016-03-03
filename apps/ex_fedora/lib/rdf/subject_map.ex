defmodule RDF.SubjectMap do
  def new do
    %{:_type_ => :subject}
  end

  def new(content_map) do
    put_in(content_map, [:_type_], :subject)
  end
end
