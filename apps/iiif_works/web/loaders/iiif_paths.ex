defmodule IIIFPaths do
  def thumbnail_id(id) do
    "#{url(id)}/full/!200,200/0/default.jpg"
  end

  def url(id) do
    "http://192.168.99.100:5004/#{id(id)}"
  end

  def id(id) do
    id = 
      id
      |> String.split("/")
      |> Enum.at(-1)
      |> String.to_char_list
      |> Enum.chunk(2,2,[])
      |> Enum.join("%2F")
    "#{id}-intermediate_file.jp2"
  end
end
