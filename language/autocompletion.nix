{
    plugins.cmp = {
        enable = true;
        settings = {
            sources = [
                { name = "nvim_lsp"; }
                { name = "buffer"; }
                { name = "path"; }
            ];
            mapping = {
                "<C-Space>" = "cmp.mapping.complete()";
                "<CR>" = "cmp.mapping.confirm({ select = true })";
                "<Tab>" = "cmp.mapping.select_next_item()";
                "<S-Tab>" = "cmp.mapping.select_prev_item()";
            };
        };
    };
    plugins.cmp-nvim-lsp.enable = true;
    plugins.cmp-buffer.enable = true;
    plugins.cmp-path.enable = true;

    extraConfigLua = ''
        vim.defer_fn(function()
            local clients = vim.lsp.get_clients()
            for _, c in ipairs(clients) do
                print(c.name .. ': ' .. vim.inspect(c.capabilities.textDocument.completion.completionItem.snippetSupport))
            end
        end, 1000)
    '';
}
