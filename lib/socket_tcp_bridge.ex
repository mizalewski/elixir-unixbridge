defmodule SocketTcpBridge do
  use GenServer

  @moduledoc """
  This is GenServer module without any public API. You can just start process with UNIX socket path and port:
  ```elixir
  {:ok, pid} = SocketTcpBridge.start_link("/var/run/docker.sock", 8000)
  ```
  and you can connect to docker using port 8000.

  Please remember to run above process using Supervisor on production!

  **Important:** Library use `socat` which need to be installed in your system.
  """

  @doc """
  Starts listener on given TCP port bound to UNIX socket.
  """
  @spec start_link(bitstring, integer) :: {atom, pid}
  def start_link(unix_socket, bind_port) when is_bitstring(unix_socket) and is_number(bind_port) do
    GenServer.start_link(__MODULE__, %{unix_socket: unix_socket, bind_port: bind_port})
  end

  def init(%{unix_socket: unix_socket, bind_port: bind_port}) do
    with {:ok, socat_filename} <- socat_exec_path(),
         {:ok, port} <- run_socat(socat_filename, unix_socket, bind_port)
    do
      Port.connect(port, self())

      {:ok, %{port: port}}
    else
      err -> {:error, err}
    end
  end

  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end

  def handle_info({_port, {:exit_status, status}}, state) do
    {:stop, {:port_exit, status}, state}
  end

  def terminate(_reason, %{port: port}) do
    try do
      Port.close(port)
    rescue
      _ ->
    end
  end

  defp socat_exec_path do
    case System.find_executable("socat") do
      false -> {:error, "'socat' executable not found"}
      filename -> {:ok, filename}
    end
  end

  defp run_socat(socat_filename, unix_socket, bind_port) do
    args = [
      socat_filename,
      "tcp-listen:#{bind_port},reuseaddr,bind=127.0.0.1,fork",
      unix_socket
    ]
    port = Port.open({:spawn_executable, :erlsh.fdlink_executable()}, [:stream, :exit_status, args: args])
    {:ok, port}
  end
end