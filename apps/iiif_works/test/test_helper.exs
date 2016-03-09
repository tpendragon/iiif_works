ExUnit.start

# Mix.Task.run "ecto.create", ~w(-r IiifWorks.Repo --quiet)
# Mix.Task.run "ecto.migrate", ~w(-r IiifWorks.Repo --quiet)
# Ecto.Adapters.SQL.begin_test_transaction(IiifWorks.Repo)
defmodule Iiif.Works.Integration.Case do
  use ExUnit.CaseTemplate

  setup_all do
    :ok
  end

  setup do
    on_exit(fn ->
      client = Fedora.Ecto.client(IiifWorks.Repo)
      ExFedora.Client.delete(client, "")
      ExFedora.Client.delete(client, "fcr:tombstone")
    end)
    :ok
  end
end
