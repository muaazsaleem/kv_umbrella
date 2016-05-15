defmodule KV do
  def start(_type, _args) do
    KV.Supervisor.start_link
  end
end
