defmodule NTriplesBench do
  use Benchfella

  @content elem(File.read("test/fixtures/content.nt"),1)

  bench "parse large file" do
    NTriples.parse(@content)
  end
end
