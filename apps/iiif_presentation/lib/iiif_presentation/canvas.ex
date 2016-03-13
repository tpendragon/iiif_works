defmodule IIIF.Presentation.Canvas do
  alias IIIF.Presentation.Validations
  @default_context "http://iiif.io/api/presentation/2/context.json"
  @rdf_type "sc:Canvas"
  @required_properties [:id, :type, :label, :width, :height]

  defstruct id: nil, context: @default_context, type: @rdf_type,
            label: nil, metadata: [], description: nil, thumbnail: nil,
            viewingHint: nil, license: nil, attribution: nil, logo: nil, related: nil,
            service: nil, seeAlso: nil, rendering: nil, within: nil,
            images: [], otherContent: [], height: nil, width: nil
  def valid?(manifest) do
    Validations.valid?(manifest, @required_properties)
  end
end
