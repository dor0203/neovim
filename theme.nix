{lib, ...}: let
  colors = {
    opts = {
      termguicolors = true;
    };
    colorschemes.moonfly.enable = true;
  };
  cursorline = {
    opts = {
      cursorline = false;
    };

    extraConfigLua = ''
      vim.api.nvim_create_autocmd("InsertEnter", {
          callback = function() vim.wo.cursorline = false end
      })
      vim.api.nvim_create_autocmd("InsertLeave", {
          callback = function() vim.wo.cursorline = true end
      })
    '';
  };

  indentation = {
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
      settings.scope.enabled = false;
    };
  };

  icons = {
    plugins.web-devicons = {
      enable = true;
      settings.color_icons = true;
    };
  };

in lib.mkMerge [cursorline icons indentation colors]
