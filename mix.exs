defmodule Iris.MixProject do
  use Mix.Project

  @iris_dir "./iris"
  @entity_js "entity.js"

  @source_url "https://github.com/rahultumpala/iris"
  @version "0.1.4"

  def project do
    [
      app: :iris,
      version: @version,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      docs: docs()
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
      {:ex_doc, "~> 0.38.4", only: :dev}
    ]
  end

  defp description() do
    "Iris is a tool for visualizing your Elixir codebase."
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "IrisUI.md"
      ],
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: [
        "CHANGELOG.md"
      ]
    ]
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
      build: ["cmd --cd assets npm run build"],
      docs: ["docs.override"]
      ]
  end

  defp package() do
    local_entity_js = Path.join(@iris_dir, @entity_js)

    if File.exists?(local_entity_js) do
      File.rm!(local_entity_js)
    end

    [
      licenses: ["Apache-2.0"],
      maintainers: ["Rahul Tumpala"],
      files: ~w(iris lib LICENSE mix.exs README.md CHANGELOG.md),
      files: ~w(iris lib LICENSE mix.exs README.md CHANGELOG.md),
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://hexdocs.pm/iris/changelog.html",
        "IrisUI" => "https://hexdocs.pm/iris/irisui.html"
      }
    ]
  end
end
