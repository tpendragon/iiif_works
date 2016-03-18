defmodule AnnotationTest do
  use ExUnit.Case
  doctest IIIF.Presentation
  alias IIIF.Presentation.Annotation
  setup do
    {:ok, manifest: %Annotation{}}
  end
  test "Annotation struct", %{manifest: manifest} do
    assert manifest.context == "http://iiif.io/api/presentation/2/context.json"
    # Descriptive and Rights Properties

    # Technical Properties
    assert manifest.id == nil
    assert manifest.type == "oa:Annotation"
    assert manifest.motivation == nil

    # Linking Properties
    assert manifest.resource == nil
    assert manifest.on == nil

    # Paging Properties

    # Structural Properties
  end

  setup do
    {:ok, valid_manifest: %Annotation{id: "http://test.com", on:
        "http://canvas", motivation: "sc:painting"}}
  end

  @required_properties [:id, :type, :on, :motivation]
  Enum.each(@required_properties, fn(property) ->
    @property property
    test "#{@property} is required", %{valid_manifest: manifest} do
      assert Annotation.valid?(%{manifest | @property => nil}) == false
    end
  end)

  test "validity checks", %{valid_manifest: manifest} do
    assert Annotation.valid?(manifest)
  end

  test "to_json", %{valid_manifest: manifest} do
    json_document = IIIF.Presentation.to_json(manifest)
    assert %{"@id" => _} = json_document
    assert %{"@context" => _} = json_document
    assert %{"@type" => _} = json_document
  end
end
