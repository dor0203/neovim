{
    plugins.noice = {
        enable = true;
        settings = {
            cmdline = {
                view = "hover";
                opts = {
                    win_options = {
                        winhighlight = {
                            Normal = "Normal";
                            FloatBorder = "Normal";
                        };
                    };
                    border = {
                        style = "none";
                        padding = [ 0 1 ];
                    };
                };
            };
            presets = {
                command_palette = true;
                long_message_to_split = true;
            };
        };
    };
}
