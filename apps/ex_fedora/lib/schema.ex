defmodule ExFedora.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import ExFedora.Schema, only: [schema: 1, property: 2]
      Module.register_attribute(__MODULE__, :exfedora_predicates, accumulate: true)
    end
  end
  defmacro schema([do: block]) do
    quote do
      Ecto.Schema.schema("metadata", do: unquote(block))
      predicates = @exfedora_predicates |> Enum.reverse
      Module.eval_quoted __ENV__, [
        ExFedora.Schema.__predicates__(predicates)
      ]
    end
  end

  defmacro property(name, opts) do
    quote do
      ExFedora.Schema.__property__(__MODULE__,
        unquote(name),
        unquote(opts)
      )
      Ecto.Schema.__field__(__MODULE__,
        unquote(name),
        :string,
        false,
        unquote(opts)
      )
    end
  end

  def __property__(mod, name, opts) do
    check_predicate!(opts[:predicate])
    Module.put_attribute(mod, :exfedora_predicates, {name, opts[:predicate]})
  end

  defp check_predicate!(predicate) when is_binary(predicate), do: :ok
  defp check_predicate!(predicate) do
    raise ArgumentError, "invalid predicate `#{inspect predicate}`, it must" <>
                         " be a string"
  end

  def __predicates__(predicates) do
    quote do
      def __schema__(:predicates), do: unquote(predicates)
    end
  end
end
