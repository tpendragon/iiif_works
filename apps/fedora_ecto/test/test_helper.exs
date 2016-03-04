ExUnit.start()

Application.put_env(:ecto, :primary_key_type, :binary_id)

Code.require_file "../../../deps/ecto/integration_test/support/repo.exs", __DIR__
Code.require_file "../../../deps/ecto/integration_test/support/schemas.exs", __DIR__
alias Ecto.Integration.TestRepo

Application.put_env(:ecto, TestRepo,
                    adapter: Fedora.Ecto,
                    url: "http://localhost:8984/rest",
                    pool_size: 20)
defmodule Ecto.Integration.TestRepo do
  use Ecto.Integration.Repo, otp_app: :ecto
end
defmodule Ecto.Integration.Case do
  use ExUnit.CaseTemplate

  setup_all do
    :ok
  end

  setup do
    :ok
  end
end
{:ok, _} = TestRepo.start_link
