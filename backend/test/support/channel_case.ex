defmodule BackendWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      import BackendWeb.ChannelCase

      @endpoint BackendWeb.Endpoint
    end
  end

  setup tags do
    Backend.DataCase.setup_sandbox(tags)
    :ok
  end
end