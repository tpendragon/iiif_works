defmodule FedoraObjectQueryTest do
  use Iiif.Works.Integration.Case
  alias IiifWorks.Repo

  test "when there is one work" do
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}]}
    result = Repo.insert!(work_node)
    Repo.get!(WorkNode, result.id)

    assert FedoraObjectQuery.from_id(Repo, WorkNode, result.id).ordered_members
    == []
  end
  test "when there is a work with a fileset" do
    file_set = Repo.insert!(%WorkNode{type: [%{"@id" =>
          "http://pcdm.org/works#FileSet"}]})
    proxy = Repo.insert!(%Proxy{proxy_for: [%{"@id" => file_set.uri}]})
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => file_set.uri}], first: [%{"@id" => proxy.uri}]}
    work_node = Repo.insert!(work_node)

    reloaded_file_set = Repo.get!(WorkNode, file_set.id)
    query_result = FedoraObjectQuery.from_id(Repo, WorkNode, work_node.id)
    assert %{ordered_members: [^reloaded_file_set]} = query_result
  end
  test "when there is two filesets" do
    file_set = Repo.insert!(%WorkNode{type: [%{"@id" =>
          "http://pcdm.org/works#FileSet"}]})
    file_set_2 = Repo.insert!(%WorkNode{type: [%{"@id" =>
          "http://pcdm.org/works#FileSet"}]})

    proxy_2 = Repo.insert!(%Proxy{proxy_for: [%{"@id" => file_set_2.uri}]})
    proxy = Repo.insert!(%Proxy{proxy_for: [%{"@id" => file_set.uri}], next:
      [%{"@id" => proxy_2.uri}]})
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => file_set.uri}], first: [%{"@id" => proxy.uri}]}
    work_node = Repo.insert!(work_node)

    reloaded_file_set = Repo.get!(WorkNode, file_set.id)
    reloaded_file_set2 = Repo.get!(WorkNode, file_set_2.id)
    query_result = FedoraObjectQuery.from_id(Repo, WorkNode, work_node.id)
    assert [^reloaded_file_set,^reloaded_file_set2] = query_result.ordered_members
  end
end
