defmodule Profilers.NTriples do
  import ExProf.Macro
  @content elem(File.read("test/fixtures/content.nt"),1)

  def profile do
    profile do
      run
    end
  end

  def profile_serialize do
    result = run
    profile do
      NTriples.serialize(result)
    end
  end

  def run do
    NTriples.parse(@content)
  end
end
