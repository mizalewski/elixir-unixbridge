# UNIX Socket to TCP Bridge

UNIX Bridge to TCP Bridge use [socat](https://www.linux.com/news/socat-general-bidirectional-pipe-handler) to create
tunnel between UNIX socket and TCP port.
Library can be used with libraries, which need TCP port but you want to use UNIX socket (e.g. for Docker).

Inspiration to create this library was erldocker_unixbridge in Erlang library for Docker: [erldocker](https://github.com/proger/erldocker).

## Installation

The package can be installed by adding `socket_tcp_bridge` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:socket_tcp_bridge, "~> 0.1.0"}]
end
```

## Usage

Just start process (in production use supervisor to monitor SocketTcpBridge process) with UNIX socket path and port:
```elixir
{:ok, pid} = SocketTcpBridge.start_link("/var/run/docker.sock", 8000)
```
and you can connect to docker using port 8000 and Docker library which support Docker HTTP API.

**Important:** Library use `socat` which need to be installed in your system.
