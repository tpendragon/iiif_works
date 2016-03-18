require IEx
defmodule Iiif.Works.ManifestLoader.ImageLoader do
  alias IIIF.Presentation.{Annotation, ImageResource, Service}
  def load(canvas, fs = %{id: id}, iiif_path_module) do
    %{canvas | images: build_images(canvas, fs, iiif_path_module)}
  end

  defp build_images(canvas, fs = %{id: id}, iiif_path_module) do
    annotation = 
      %Annotation{}
      |> Map.put(:id, "#{canvas.id}/annotation/#{id}")
      |> Map.put(:motivation, "sc:Painting")
      |> Map.put(:on, canvas.id)
      |> Map.put(:resource, build_resource(canvas, fs, iiif_path_module))
    [annotation]
  end

  defp build_resource(canvas, fs = %{id: id}, iiif_path_module) do
    %ImageResource{}
    |> Map.put(:id, iiif_path_module.thumbnail_id(id))
    |> Map.put(:format, "image/jpeg")
    |> Map.put(:width, canvas.width)
    |> Map.put(:height, canvas.height)
    |> Map.put(:service, build_service(canvas, fs, iiif_path_module))
  end

  defp build_service(canvas, %{id: id}, iiif_path_module) do
    %Service{}
    |> Map.put(:id, iiif_path_module.url(id))
    |> Map.put(:context, "http://iiif.io/api/image/2/context.json")
    |> Map.put(:profile, "http://iiif.io/api/image/2/level2.json")
  end

end
