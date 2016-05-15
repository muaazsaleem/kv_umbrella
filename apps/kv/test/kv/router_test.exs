defmodule KV.RouterTest do
  use ExUnit.Case, async: true
  @tag :distributed
  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) ==
           :"foo@plumgrid-Latitude-E5530-non-vPro"
    assert KV.Router.route("world", Kernel, :node, []) ==
           :"bar@plumgrid-Latitude-E5530-non-vPro"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/Could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end