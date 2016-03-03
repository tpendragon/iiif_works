defmodule ExFedora.Schema do
  defmacro __using__(_) do
    quote do
      require Ecto.Schema
      import ExFedora.Schema, only: [schema: 2, property: 2]
      @primary_key {:id, :binary_id, autogenerate: true}
      @timestamps_opts []
      @foreign_key_type :id
      @ecto_embedded false
      @schema_prefix nil

      Module.register_attribute(__MODULE__, :ecto_primary_keys, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_assocs, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_embeds, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_raw, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_autogenerate_insert, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_autogenerate_update, accumulate: true)
      Module.register_attribute(__MODULE__, :exfedora_predicates, accumulate: true)
      Module.put_attribute(__MODULE__, :ecto_autogenerate_id, nil)
    end
  end
  defmacro schema(name, [do: block]) do
    quote do
      Module.register_attribute(__MODULE__, :struct_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :changeset_fields, accumulate: true)
      Module.put_attribute(__MODULE__, :struct_fields, {:unmapped_graph, %{}})
      Module.put_attribute(__MODULE__, :ecto_fields, {:unmapped_graph, :map})
      Module.put_attribute(__MODULE__, :changeset_fields, {:unmapped_graph, :map})
      Ecto.Schema.schema(unquote(name), do: unquote(block))
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
        RDF.Literal,
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
