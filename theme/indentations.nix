{
    opts = {
        softtabstop = 4;
        tabstop = 4;
        shiftwidth = 4;
        expandtab = true;

        list = true;
        listchars = {
            trail = "·";
            tab = "→ ";
            extends = "»";
            precedes = "«";
            nbsp = "␣";
        };
    };

    plugins.indent-blankline={
        enable = true;
    };
}
