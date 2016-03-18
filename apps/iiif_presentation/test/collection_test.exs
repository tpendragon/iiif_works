defmodule CollectionTest do
  use ExUnit.Case
  doctest IIIF.Presentation
  alias IIIF.Presentation.Collection
  setup do
    {:ok, manifest: %Collection{}}
  end
  test "Collection struct", %{manifest: manifest} do
    assert manifest.context == "http://iiif.io/api/presentation/2/context.json"
    # Descriptive and Rights Properties
    assert manifest.label == nil
    assert manifest.description == nil
    assert manifest.thumbnail == nil
    assert manifest.attribution == nil
    assert manifest.license == nil
    assert manifest.logo == nil

    # Technical Properties
    assert manifest.id == nil
    assert manifest.type == "sc:Collection"
    assert manifest.viewingHint == nil
    assert manifest.navDate == nil

    # Linking Properties
    assert manifest.seeAlso == nil
    assert manifest.service == nil
    assert manifest.related == nil
    assert manifest.rendering == nil
    assert manifest.within == nil

    # Paging Properties
    assert manifest.first == nil
    assert manifest.last == nil
    assert manifest.total == nil
    assert manifest.next == nil
    assert manifest.prev == nil
    assert manifest.startIndex == nil

    # Structural Properties
    assert manifest.collections == []
    assert manifest.manifests == []
    assert manifest.members == []
  end

  setup do
    {:ok, valid_manifest: %Collection{label: "Test", id: "http://test.com"}}
  end

  @required_properties [:label, :id, :type]
  Enum.each(@required_properties, fn(property) ->
    @property property
    test "#{@property} is required", %{valid_manifest: manifest} do
      assert Collection.valid?(%{manifest | @property => nil}) == false
    end
  end)

  test "validity checks", %{valid_manifest: manifest} do
    assert Collection.valid?(manifest)
  end

  test "to_json", %{valid_manifest: manifest} do
    json_document = IIIF.Presentation.to_json(manifest)
    assert %{"@id" => _} = json_document
    assert %{"@context" => _} = json_document
    assert %{"@type" => _} = json_document
  end
end
