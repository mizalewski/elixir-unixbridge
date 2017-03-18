defmodule SocketTcpBridge.Mixfile do
  use Mix.Project

  def project do
    [app: :socket_tcp_bridge,
     version: "0.1.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp description do
    """
    Bridge between unix socket and tcp port. You can redirect UNIX socket (e.g. Docker API) to TCP port.
    """
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:erlsh, "~> 0.1.0"},
    {:ex_doc, "~> 0.15.0", only: :dev}]
  end

   defp package do
    [name: :socket_tcp_bridge,
          files: ["lib", "test", "mix.exs", "mix.lock", "README*", "LICENSE*"],
          maintainers: ["Michał Zalewski"],
          licenses: ["MIT"],
          links: %{"GitHub" => "https://github.com/mizalewski/elixir-unixbridge"}]
   end
end
