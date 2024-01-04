defmodule Imgspider.MixProject do
  use Mix.Project

  def project do
    [
      app: :imgspider,
      version: "0.1.0",
      elixir: "~> 1.15",
      escript: escript(),
      default_task: "escript.build",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help escript" to learn about that shit
  #
  # For me, escript is a thing which make a CLI application
  #
  # "mix escript.build"
  #    build CLI application.  The executable file will be located at
  #    the project root directory
  #
  # "mix escript.install"
  #    now u can use this application just with type the name
  #    ("imgspider") in the terminal everywhere, like it's a normal
  #    program WoWW!
  def escript do
    [main_module: Imgspider.CLI]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:finch, "~> 0.16.0"}]
  end
end
