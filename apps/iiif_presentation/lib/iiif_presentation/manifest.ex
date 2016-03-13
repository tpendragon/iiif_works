defmodule IIIF.Presentation.Manifest do
  alias IIIF.Presentation.Validations
  @default_context "http://iiif.io/api/presentation/2/context.json"
  @rdf_type "sc:Manifest"
  @required_properties [:id, :type, :label]
  defstruct id: nil, canvases: [], context: @default_context, type: @rdf_type,
            label: nil, metadata: [], description: nil, thumbnail: nil,
            viewingHint: nil, viewingDirection:  nil, navDate: nil,
            license: nil, attribution: nil, logo: nil, related: nil,
            service: nil, seeAlso: nil, rendering: nil, within: nil,
            sequences: []

  def valid?(manifest) do
    Validations.valid?(manifest, @required_properties)
  end

end
