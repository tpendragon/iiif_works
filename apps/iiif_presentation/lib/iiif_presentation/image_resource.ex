defmodule IIIF.Presentation.ImageResource do
  alias IIIF.Presentation.Validations
  @rdf_type "dctypes:Image"
  @required_properties [:id, :type]

  @technical_properties   id: nil, type: @rdf_type, format: nil, height: nil,
                          width: nil
  @linking_properties     service: nil

  defstruct @technical_properties ++ @linking_properties

  def valid?(manifest) do
    Validations.valid?(manifest, @required_properties)
  end
end
