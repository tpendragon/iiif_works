defmodule IiifWorks.ManifestView do
  use IiifWorks.Web, :view
  def render("show.json", %{data: data}) do
    data
    |> IIIF.Presentation.to_json()
  end
end
