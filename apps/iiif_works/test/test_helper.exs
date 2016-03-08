ExUnit.start

Mix.Task.run "ecto.create", ~w(-r IiifWorks.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r IiifWorks.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(IiifWorks.Repo)

