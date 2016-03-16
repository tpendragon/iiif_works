defmodule Iiif.Works.ManifestLoader.NullLoader do
  alias IIIF.Presentation.Manifest
  def load(_, _), do: %Manifest{}
end
