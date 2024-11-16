defmodule BackendWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  def header(assigns) do
    ~H"""
    <header class={["px-4 sm:px-6 lg:px-8", @class]}>
      <div class="flex items-center justify-between border-b border-zinc-100 py-3 text-sm">
        <div class="flex items-center gap-4">
          <a href="/" class="hover:text-zinc-700">
            Nexus Browser
          </a>
        </div>
      </div>
    </header>
    """
  end

  @doc """
  Renders a button.
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any
  attr :type, :string, default: "text"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(autocomplete disabled form max maxlength min minlength pattern placeholder readonly required size step)

  def input(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= if @label do %>
        <label for={@id || @name} class="block text-sm font-medium leading-6 text-zinc-800">
          <%= @label %>
        </label>
      <% end %>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={[
          "block w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5",
          @class
        ]}
        {@rest}
      />
    </div>
    """
  end
end
