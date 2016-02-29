defmodule NTriplesBench do
  use Benchfella

  @content elem(File.read("test/fixtures/content.nt"),1)

  bench "parse large file" do
    NTriples.parse(@content)
  end

  bench "serializing n-triples", [map: gen_ntriples_map()] do
    NTriples.serialize(map)
  end

  defp gen_ntriples_map do
    NTriples.parse(@content)
  end
end
