defmodule WorkNode do
  use ExFedora.Schema
  schema "" do
    property :type, predicate:
      "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
    property :members, predicate:
      "http://pcdm.org/models#hasMember"
    property :first, predicate:
      "http://www.iana.org/assignments/relation/first"
    property :label, predicate:
      "http://www.w3.org/1999/02/22-rdf-syntax-ns#label"
    property :description, predicate:
      "http://purl.org/dc/terms/description"
    property :width, predicate:
      "http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#width"
    property :height, predicate:
      "http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#height"
  end
end
