defmodule IIIF.Presentation.Collection do
  alias IIIF.Presentation.Validations
  @default_context "http://iiif.io/api/presentation/2/context.json"
  @rdf_type "sc:Collection"
  @required_properties [:label, :id, :type]

  @descriptive_and_rights context: @default_context, label: nil,
                          description: nil, thumbnail: nil, attribution: nil,
                          license: nil, logo: nil
  @technical_properties   id: nil, type: @rdf_type, viewingHint: nil,
                          navDate: nil
  @linking_properties     seeAlso: nil, service: nil, related: nil,
                          rendering: nil, within: nil
  @paging_properties      first: nil, last: nil, total: nil, next: nil,
                          prev: nil, startIndex: nil
  @structural_properties  collections: [], manifests: [], members: []

  defstruct @descriptive_and_rights ++ @technical_properties ++
            @linking_properties ++ @paging_properties ++ @structural_properties

  def valid?(manifest) do
    Validations.valid?(manifest, @required_properties)
  end
end
