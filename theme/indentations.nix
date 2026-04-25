{
  opts = {
    softtabstop = 2;
    tabstop = 2;
    shiftwidth = 2;
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

  plugins.indent-blankline = {
    enable = true;
  };
}
