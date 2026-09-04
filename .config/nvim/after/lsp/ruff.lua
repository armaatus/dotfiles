return {
  on_attach = function(client)
    -- pyright handles hover; disable it in ruff to avoid conflicts
    client.server_capabilities.hoverProvider = false
  end,
}
