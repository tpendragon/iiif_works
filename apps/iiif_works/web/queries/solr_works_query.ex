require IEx
defmodule SolrWorksQuery do
  def from_id(work_node, id) do
    doc = solr_document(id)
    ordered_ids = ordered_ids(id)
    all_docs = solr_document(ordered_ids)
    work = doc |> build_work(work_node)
    all_docs = Enum.map(all_docs, &build_work(&1, work_node))
    work
    |> Map.put(:ordered_members, all_docs)
  end

  defp solr_document(ids) when is_list(ids) do
    ids
    |> Enum.map(&Task.async(fn -> solr_document(&1) end))
    |> Enum.map(&Task.await/1)
  end
  defp solr_document(id) do
    solr_query("id:#{id}")
    |> Enum.at(0)
  end

  defp build_work(document, work_node) do
    struct(work_node, %{})
    |> Map.put(:type, type(document))
    |> Map.put(:label, document["title_tesim"])
    |> Map.put(:id, document["id"])
    |> apply_properties(document)
  end

  defp apply_properties(work_node = %{type: [%{"@id" => "http://pcdm.org/works#Work"}]}, document) do
    work_node
  end
  defp apply_properties(work_node = %{type: [%{"@id" => "http://pcdm.org/works#FileSet"}]}, document) do
    work_node
    |> Map.put(:height, document["height_is"])
    |> Map.put(:width, document["width_is"])
  end

  defp type(%{"active_fedora_model_ssi" => model}) do
    case model do
      "ScannedResource" ->
        [%{"@id" => "http://pcdm.org/works#Work"}]
      "FileSet" ->
        [%{"@id" => "http://pcdm.org/works#FileSet"}]
      "MultiVolumeWork" ->
        [%{"@id" => "http://pcdm.org/works#Work"}]
    end
  end

  defp ordered_ids(id) do
    solr_query("proxy_in_ssi:#{id}", fl: "ordered_targets_ssim")
    |> Enum.at(0)
    |> get_in(["ordered_targets_ssim"])
  end

  defp solr_query(query, opts \\ %{}) do
    HTTPoison.get(solr_url, [], 
      params: Enum.into(%{
        q: query,
        wt: "json",
        rows: 100000
      }, opts)
    )
    |> elem(1)
    |> Map.fetch(:body)
    |> elem(1)
    |> Poison.decode!
    |> get_in(["response","docs"])
  end

  defp solr_url do
    Application.get_env(:iiif_works, IiifWorks.Endpoint)[:solr_url]
  end
end
