defmodule ExFedora.Node do
  use ExFedora.Schema

  schema "nodes" do
    property :contains, predicate: "http://www.w3.org/ns/ldp#contains"
  end
end
