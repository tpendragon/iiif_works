require IEx
defmodule CanvasTest do
  use ExUnit.Case
  doctest IIIF.Presentation
  alias IIIF.Presentation.Canvas
  setup do
    {:ok, manifest: %Canvas{}}
  end
  test "Canvas struct", %{manifest: manifest} do
    assert manifest.id == nil
    # Structure
    assert manifest.images == []
    assert manifest.otherContent == []
    # Static Metadata
    assert manifest.context == "http://iiif.io/api/presentation/2/context.json"
    assert manifest.type == "sc:Canvas"
    # Basic Metadata
    assert manifest.label == nil
    assert manifest.metadata == []
    assert manifest.description == nil
    # Services
    assert manifest.thumbnail == nil
    assert manifest.logo == nil
    # Presentation Information
    assert manifest.viewingHint == nil
    assert manifest.height == nil
    assert manifest.width == nil
    # Rights
    assert manifest.license == nil
    assert manifest.attribution == nil
    # Links
    assert manifest.related == nil
    assert manifest.service == nil
    assert manifest.seeAlso == nil
    assert manifest.rendering == nil
    assert manifest.within == nil
  end

  setup do
    {:ok, valid_manifest: %Canvas{label: "Test", id: "http://test.com", width:
        0, height: 0}}
  end

  @required_properties [:id, :type, :label, :width, :height]
  Enum.each(@required_properties, fn(property) ->
    @property property
    test "#{@property} is required", %{valid_manifest: manifest} do
      assert Canvas.valid?(%{manifest | @property => nil}) == false
    end
  end)

  test "validity checks", %{valid_manifest: manifest} do
    assert Canvas.valid?(manifest)
  end

  test "to_json", %{valid_manifest: manifest} do
    json_document = IIIF.Presentation.to_json(manifest)
    assert Map.has_key?(json_document, :license) == false
    assert Map.has_key?(json_document, :sequences) == false
    assert Map.has_key?(json_document, :images) == false
    assert Map.has_key?(json_document, :otherContent) == false
    assert %{"@id" => _} = json_document
    assert %{"@context" => _} = json_document
    assert %{"@type" => _} = json_document
  end
end
