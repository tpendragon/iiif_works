require IEx
defmodule FedoraObjectQueryTest do
  use Iiif.Works.Integration.Case, async: true
  alias IiifWorks.Repo

  test "when there is one work" do
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}]}
    result = Repo.insert!(work_node)
    new_result = Repo.get!(WorkNode, result.id)

    assert FedoraObjectQuery.from_id(Repo, WorkNode, result.id).ordered_members
    == []
  end
  test "when there is a work with a fileset" do
    client = Fedora.Ecto.client(Repo)
    file_set = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#FileSet"}]}
    file_set = Repo.insert!(file_set)
    full_file_set_id = ExFedora.Client.id_to_url(client, file_set.id)
    proxy = Repo.insert!(%Proxy{proxy_for: [%{"@id" => full_file_set_id}]})
    full_proxy_id = ExFedora.Client.id_to_url(client, proxy.id)
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => full_file_set_id}], first: [%{"@id" => full_proxy_id}]}
    work_node = Repo.insert!(work_node)

    reloaded_file_set = Repo.get!(WorkNode, file_set.id)
    query_result = FedoraObjectQuery.from_id(Repo, WorkNode, work_node.id)
    assert %{ordered_members: [^reloaded_file_set]} = query_result
  end
  test "when there is two filesets" do
    client = Fedora.Ecto.client(Repo)
    file_set = Repo.insert!(%WorkNode{type: [%{"@id" =>
          "http://pcdm.org/works#FileSet"}]})
    file_set_2 = Repo.insert!(%WorkNode{type: [%{"@id" =>
          "http://pcdm.org/works#FileSet"}]})
    full_file_set_id = ExFedora.Client.id_to_url(client, file_set.id)
    full_file_set_id_2 = ExFedora.Client.id_to_url(client, file_set_2.id)

    proxy_2 = Repo.insert!(%Proxy{proxy_for: [%{"@id" => full_file_set_id_2}]})
    proxy_2_id = ExFedora.Client.id_to_url(client, proxy_2.id)
    proxy = Repo.insert!(%Proxy{proxy_for: [%{"@id" => full_file_set_id}], next:
      [%{"@id" => proxy_2_id}]})
    full_proxy_id = ExFedora.Client.id_to_url(client, proxy.id)
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => full_file_set_id}], first: [%{"@id" => full_proxy_id}]}
    work_node = Repo.insert!(work_node)

    reloaded_file_set = Repo.get!(WorkNode, file_set.id)
    reloaded_file_set2 = Repo.get!(WorkNode, file_set_2.id)
    query_result = FedoraObjectQuery.from_id(Repo, WorkNode, work_node.id)
    assert [^reloaded_file_set,^reloaded_file_set2] = query_result.ordered_members
  end
end
