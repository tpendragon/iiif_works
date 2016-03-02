defmodule ExFedora.Model do
  defmacro __using__(_) do
    quote do
      import ExFedora.Model
      use ExFedora.Schema
    end
  end

  def from_graph(mod, subject, graph = %{}) when is_binary(subject) do
    struct(mod, %{})
  end
end
