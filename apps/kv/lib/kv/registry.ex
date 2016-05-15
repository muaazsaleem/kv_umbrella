defmodule KV.Registry do
  use GenServer
  @moduledoc """
  Registers stuff
  """

  ## client API
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  def stop(server) do
    GenServer.stop(server)
  end

  ## Server Callbacks
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  def handle_call({:create, name}, _from, {names, refs}) do
    if Map.has_key?(names, name) do
      {:reply, :ok, {names, refs}}
    else
      {:ok, bucket} = KV.Bucket.Supervisor.start_bucket
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:reply, :ok, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end