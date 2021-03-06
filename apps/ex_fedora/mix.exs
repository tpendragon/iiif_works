defmodule ExFedora.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_fedora,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison],
     mod: {ExFedora, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.8.0"},
      {:poison, "~> 1.0"},
      {:benchwarmer, "~> 0.0.2", only: [:dev, :test]},
      {:benchfella, "~> 0.3.0", only: [:dev, :test]},
      {:exprof, "~> 0.2.0", only: [:dev, :test]},
      {:dogma, "~> 0.0", only: :dev},
      {:ecto, "~> 2.0.0-beta.1"}
    ]
  end
end
