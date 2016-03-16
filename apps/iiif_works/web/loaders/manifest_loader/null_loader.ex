defmodule Iiif.Works.ManifestLoader.NullLoader do
  alias IIIF.Presentation.Manifest
  def load(manifest, _, _), do: manifest

  def generate do
    %Manifest{}
  end
end
