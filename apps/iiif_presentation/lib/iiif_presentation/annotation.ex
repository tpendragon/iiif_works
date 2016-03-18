defmodule IIIF.Presentation.Annotation do
  alias IIIF.Presentation.Validations
  @default_context "http://iiif.io/api/presentation/2/context.json"
  @rdf_type "oa:Annotation"
  @required_properties [:id, :type, :on, :motivation]

  @descriptive_and_rights context: @default_context
  @technical_properties   id: nil, type: @rdf_type, motivation: nil
  @linking_properties     resource: nil, on: nil 

  defstruct @descriptive_and_rights ++ @technical_properties ++
            @linking_properties

  def valid?(manifest) do
    Validations.valid?(manifest, @required_properties)
  end
end
