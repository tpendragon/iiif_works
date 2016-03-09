defmodule Proxy do
  use ExFedora.Schema
  schema "" do
    property :next, predicate:
    "http://www.iana.org/assignments/relation/next"
    property :proxy_for, predicate:
    "http://www.openarchives.org/ore/terms/proxyFor"
  end
end
