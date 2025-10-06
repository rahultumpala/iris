defmodule Iris.MixProject do
  use Mix.Project

  @source_url "https://github.com/rahultumpala/iris"
  @version "0.1.1"

  def project do
    [
      app: :iris,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.38.4"}
    ]
  end

   defp description() do
    "Iris is a tool for visualizing your Elixir codebase."
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd --cd assets npm install"],
      build: ["cmd --cd assets npm run build"]
    ]
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      maintainers: ["Rahul Tumpala"],
      files: ~w(iris lib LICENSE mix.exs README.md CHANGELOG.md),
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
