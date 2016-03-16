defmodule SequenceTest do
  use ExUnit.Case
  doctest IIIF.Presentation
  alias IIIF.Presentation.Sequence
  setup do
    {:ok, manifest: %Sequence{}}
  end
  test "Canvas struct", %{manifest: manifest} do
    assert manifest.id == nil
    # Structure
    assert manifest.canvases == []
    # Static Metadata
    assert manifest.context == "http://iiif.io/api/presentation/2/context.json"
    assert manifest.type == "sc:Sequence"
    # Basic Metadata
    assert manifest.label == nil
    assert manifest.metadata == []
    assert manifest.description == nil
    # Services
    assert manifest.thumbnail == nil
    assert manifest.logo == nil
    # Presentation Information
    assert manifest.viewingHint == nil
    assert manifest.viewingDirection == nil
    # Rights
    assert manifest.license == nil
    assert manifest.attribution == nil
    # Links
    assert manifest.related == nil
    assert manifest.service == nil
    assert manifest.seeAlso == nil
    assert manifest.rendering == nil
    assert manifest.startCanvas == nil
    assert manifest.within == nil
  end

  setup do
    {:ok, valid_manifest: %Sequence{label: "Test", id: "http://test.com"}}
  end

  @required_properties [:type, :canvases]
  Enum.each(@required_properties, fn(property) ->
    @property property
    test "#{@property} is required", %{valid_manifest: manifest} do
      assert Sequence.valid?(%{manifest | @property => nil}) == false
    end
  end)

  test "validity checks", %{valid_manifest: manifest} do
    assert Sequence.valid?(manifest)
  end

  test "to_json", %{valid_manifest: manifest} do
    json_document = IIIF.Presentation.to_json(manifest)
    assert Map.has_key?(json_document, :canvases) == true
    assert %{"@id" => _} = json_document
    assert %{"@context" => _} = json_document
    assert %{"@type" => _} = json_document
  end
end
