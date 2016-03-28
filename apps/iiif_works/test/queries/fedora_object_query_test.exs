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
  test "when there is a work with a part with a fileset" do
    file_set = Repo.insert!(%WorkNode{type: [%{"@id" =>
          "http://pcdm.org/works#FileSet"}]})
    part = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => file_set.uri}]}
    part = Repo.insert!(part)
    proxy = Repo.insert!(%Proxy{proxy_for: [%{"@id" => part.uri}]})
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => part.uri}], first: [%{"@id" => proxy.uri}]}
    work_node = Repo.insert!(work_node)

    reloaded_file_set = Repo.get!(WorkNode, file_set.id)
    query_result = FedoraObjectQuery.from_id(Repo, WorkNode, work_node.id)
    assert %{proxies: [%{proxy_for: [_part]}]} = query_result
    assert %{ordered_members: [%{members: [^reloaded_file_set]}]} = query_result
  end
  test "when there is two parts" do
    file_set = Repo.insert!(%WorkNode{type: [%{"@id" =>
          "http://pcdm.org/works#FileSet"}]})
    file_set_2 = Repo.insert!(%WorkNode{type: [%{"@id" =>
          "http://pcdm.org/works#FileSet"}]})


    part1 = Repo.insert!(%WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => file_set.uri}]})
    part2 = Repo.insert!(%WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => file_set_2.uri}]})

    proxy_2 = Repo.insert!(%Proxy{proxy_for: [%{"@id" => part2.uri}]})
    proxy = Repo.insert!(%Proxy{proxy_for: [%{"@id" => part1.uri}], next:
      [%{"@id" => proxy_2.uri}]})
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}], first: [%{"@id" => proxy.uri}]}
    work_node = Repo.insert!(work_node)

    reloaded_file_set = Repo.get!(WorkNode, file_set.id)
    reloaded_file_set2 = Repo.get!(WorkNode, file_set_2.id)
    query_result = FedoraObjectQuery.from_id(Repo, WorkNode, work_node.id)
    assert [%{members: [^reloaded_file_set]},%{members: [^reloaded_file_set2]}] = query_result.ordered_members
  end
  test "when there is a work with a work and no filesets" do
    work = Repo.insert!(%WorkNode{
      type: [%{"@id" => "http://pcdm.org/works#Work"}]
    })
    proxy = Repo.insert!(%Proxy{proxy_for: [%{"@id" => work.uri}]})
    work_node = %WorkNode{type: [%{"@id" => "http://pcdm.org/works#Work"}],
      members: [%{"@id" => work.uri}], first: [%{"@id" => proxy.uri}]}
    work_node = Repo.insert!(work_node)

    reloaded_work = Repo.get!(WorkNode, work.id)
    query_result = FedoraObjectQuery.from_id(Repo, WorkNode, work_node.id)

    assert [^reloaded_work] = query_result.ordered_members
  end
end
