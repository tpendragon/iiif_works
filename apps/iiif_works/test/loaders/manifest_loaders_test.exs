require IEx
defmodule ManifestLoaderTest do
  use Iiif.Works.Integration.Case, async: true
  alias Iiif.Works.ManifestLoader
  alias IIIF.Presentation.Manifest
  alias IIIF.Presentation.Collection

  test "loading a work with two filesets" do
    work = build_work("test")
    fs1 = build_file_set("123456789")
    fs2 = build_file_set("012345678")
    work = Map.put(work, :ordered_members, [fs1, fs2])

    manifest = ManifestLoader.from(work, fn(x) -> "http://bla.org/#{x}" end)
    assert %Manifest{} = manifest
    assert manifest.id == "http://bla.org/test"
    assert length(manifest.sequences) == 1
    first_sequence = Enum.at(manifest.sequences, 0)
    assert length(first_sequence.canvases) == 2
    first_canvas = Enum.at(first_sequence.canvases, 0)
    assert first_canvas.id == "http://bla.org/test/canvas/#{fs1.id}"
    assert first_canvas.height == 0
    assert first_canvas.width == 0
    assert first_canvas.label == "A File"
    images = first_canvas.images
    assert length(first_canvas.images) == 1
    first_image = Enum.at(images, 0)
    assert first_image.on == first_canvas.id
  end

  test "loading a work with two works" do
    work = build_work("test")
    child_work1 = build_work("fs1")
    child_work2 = build_work("fs2")
    work = Map.put(work, :ordered_members, [child_work1, child_work2])

    manifest = ManifestLoader.from(work, fn(x) -> "http://bla.org/#{x}" end)
    assert %Collection{} = manifest
    assert manifest.id == "http://bla.org/test"
    assert length(manifest.manifests) == 2
    assert Enum.at(manifest.manifests,0).id == "http://bla.org/fs1"
    assert Enum.at(manifest.manifests,0).label == "A Work"
  end

  defp build_work(id) do
    %WorkNode{
      id: id,
      type: [ %{"@id" => "http://pcdm.org/works#Work"}],
      title: ["A Work"]
    }
  end

  defp build_file_set(id) do
    %WorkNode{
      id: id,
      type: [ %{"@id" => "http://pcdm.org/works#FileSet"}],
      label: ["A File"],
      height: ["0"],
      width: ["0"]
    }
  end
end
