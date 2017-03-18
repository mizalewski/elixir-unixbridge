defmodule UnixBridge do
  use GenServer

  def start_link(bind_port) when is_number(bind_port) do
    GenServer.start_link(__MODULE__, bind_port)
  end

  def init(bind_port) do
    socat_filename = case System.find_executable("socat") do
      false -> {:error, "'socat' executable not found"}
      filename -> filename
    end

    args = [
      socat_filename,
      "tcp-listen:#{bind_port},reuseaddr,bind=127.0.0.1,fork",
      "unix-connect:/var/run/docker.sock"
    ]
    port = Port.open({:spawn_executable, :erlsh.fdlink_executable()}, [:stream, :exit_status, args: args])
    Port.connect(port, self())

    {:ok, %{port: port}}
  end

  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end

  def handle_info({_port, {:exit_status, status}}, state) do
    IO.puts "terminating"
    {:stop, {:port_exit, status}, state}
  end

  def terminate(_reason, %{port: port}) do
    try do
      Port.close(port)
    rescue
      _ ->
    end
  end
end