defmodule FedoraNode do
  use ExFedora.Schema
  schema "" do
    property :contains, predicate: "http://www.w3.org/ns/ldp#contains"
  end
end
