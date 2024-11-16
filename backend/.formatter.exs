[
  plugins: [
    ElixirLS,
    EditorConfig,
    InjectCop,
    InlayHints,
    Tailwindcss,
    UnusedImports
  ],
  import_deps: [:phoenix],
  inputs: [
    "*.{ex,exs}",
    "{config,lib,test}/**/*.{ex,exs}",
    "mix.exs",
    "rel/overlays/*/etc/*.{ex,exs}",
    "rel/overlays/*/lib/*/etc/*.{ex,exs}"
  ]
]
