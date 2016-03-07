require IEx
defmodule IIIFPresentationTest do
  use ExUnit.Case
  doctest IIIF.Presentation
  alias IIIF.Presentation.Manifest
  setup do
    {:ok, manifest: %IIIF.Presentation.Manifest{}}
  end
  test "IIIF.Presentation.Manifest struct", %{manifest: manifest} do
    assert manifest.id == nil
    # Structure
    assert manifest.canvases == []
    assert manifest.sequences == []
    # Static Metadata
    assert manifest.context == "http://iiif.io/api/presentation/2/context.json"
    assert manifest.type == "sc:Manifest"
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
    assert manifest.navDate == nil
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
    {:ok, valid_manifest: %Manifest{label: "Test", id: "http://test.com"}}
  end

  @required_properties [:id, :type, :label]
  Enum.each(@required_properties, fn(property) ->
    @property property
    test "#{@property} is required", %{valid_manifest: manifest} do
      assert Manifest.valid?(%{manifest | @property => nil}) == false
    end
  end)

  test "validity checks", %{valid_manifest: manifest} do
    assert Manifest.valid?(manifest)
  end

  test "to_json", %{valid_manifest: manifest} do
    json_document = Manifest.to_json(manifest)
    assert Map.has_key?(json_document, :license) == false
    assert Map.has_key?(json_document, :sequences) == false
    assert %{"@id" => _} = json_document
    assert %{"@context" => _} = json_document
    assert %{"@type" => _} = json_document
  end
end