{ lib, ... }:
let
  notificatios = {
    plugins.notify = {
      enable = true;
      settings = {
        background_colour = "#ffffff";
        render = "compact";
        timeout = 500;
        stages.__raw = ''
          (function(direction)
              local stages_util = require('notify.stages.util')
              return {
                  function(state)
                      local next_height = state.message.height + 2
                      local next_row = stages_util.available_slot(state.open_windows, next_height, direction)
                      if not next_row then
                          return nil
                      end
                      return {
                          relative = 'cursor',
                          anchor = 'NW',
                          width = 1,
                          height = state.message.height,
                          col = -1,
                          row = 1,
                          border = {
                              "",
                              "",
                              "",
                              " ",
                              "",
                              "",
                              "",
                              " ",
                          },
                          style = 'minimal',
                          opacity = 0,
                      }
                  end,
                  function(state)
                      return {
                          width = { state.message.width },
                          opacity = { 100 },
                      }
                  end,
                  function()
                      return {
                          time = true,
                      }
                  end,
                  function()
                      return {
                          opacity = {
                              0,
                              frequency = 2,
                          },
                          width = { 1, frequency = 2 }
                      }
                  end,
              }
          end)("bottom_up")
        '';
      };
    };

    extraConfigLua = ''
      vim.api.nvim_create_autocmd("CmdlineEnter", {
          callback = function()
              require('notify').dismiss({ silent = true })
          end,
      })
    '';
  };
in
lib.mkMerge [ notificatios ]
