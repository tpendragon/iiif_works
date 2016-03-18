defmodule ManifestControllerTest do
  use IiifWorks.ConnCase

  test "generates JSON manifest" do
    work_node = create_work_node

    response = get(conn, manifest_path(conn, :show, String.split(work_node.id, "/")))
    assert json_response(response, 200)
  end

  test "works for deep IDs" do
    work_node = create_work_node

    response = get(conn, "/#{work_node.id}")
    assert json_response(response, 200)
  end

  defp create_work_node do
    file_set = Repo.insert!(%WorkNode{type: [%{"@id" =>
          "http://pcdm.org/works#FileSet"}], width: "100", height: "100"})
    proxy = Repo.insert!(%Proxy{proxy_for: [%{"@id" => file_set.uri}]})
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => file_set.uri}], first: [%{"@id" => proxy.uri}]}
    Repo.insert!(work_node)
  end
end
