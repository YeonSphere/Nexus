defmodule BackendWeb.PageHTML do
  use BackendWeb, :html

  embed_templates "page_html/*"

  def home(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl py-32 sm:py-48 lg:py-56">
      <div class="text-center">
        <h1 class="text-4xl font-bold tracking-tight text-zinc-900 sm:text-6xl">
          Welcome to Nexus Browser
        </h1>
        <p class="mt-6 text-lg leading-8 text-zinc-600">
          A modern, efficient, and secure web browser with integrated ad-blocking.
        </p>
      </div>
    </div>
    """
  end
end
