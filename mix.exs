defmodule MovespaceDbUploaderCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :movespace_db_uploader_cli,
      version: "0.1.0",
      # elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: MovespaceDbUploaderCli.CLI] # for the build of cli tool.
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:embedbase_ex, "~> 0.1.0"},
      # markdown
      {:earmark, "~> 1.4"},
      {:nimble_csv, "~> 1.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
