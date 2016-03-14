defmodule IIIF.Presentation.Validations do
  def valid?(manifest, required_properties) do
    manifest = Map.from_struct(manifest)
    required_properties
    |> Enum.map(&value_present?(manifest, &1))
    |> Enum.uniq
    |> (&(&1 == [true])).()
  end

  defp value_present?(manifest, property) do
    case manifest[property] do
      nil ->
        false
      [] ->
        case property do
          :canvases ->
            true
          _ ->
            false
        end
      _ ->
        true
    end
  end
end
