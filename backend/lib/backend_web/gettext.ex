defmodule BackendWeb.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](https://hexdocs.pm/gettext),
  your module gains a set of macros for translations.

  For more information, see the [Gettext Docs](https://hexdocs.pm/gettext).
  """
  use Gettext.Backend, otp_app: :backend
end
