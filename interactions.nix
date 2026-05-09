{ lib, ... }:
let
  cmdline = {
    plugins.noice = {
      enable = true;
      settings = {
        cmdline = {
          view = "hover";
          opts = {
            win_options = {
              winhighlight = {
                Normal = "NoiceCmdline";
                FloatBorder = "NoiceCmdlineBorder";
              };
            };
            border = {
              style = "none" /*[ "" "" "" "▐" "" "" "" "▌" ]*/;
              padding = [
                0
                1
              ];
            };
          };
        };
        presets = {
          command_palette = true;
          long_message_to_split = true;
        };
      };
    };

    extraConfigLua = ''
      vim.api.nvim_set_hl(0, "NoiceCmdline", {bg = "#0d1133", blend = 30})
      vim.api.nvim_set_hl(0, "NoiceCmdlineBorder", {fg="#ffffff"})

      local cmdline_ns = vim.api.nvim_create_namespace("cmdline_line_highlight")

      vim.api.nvim_create_autocmd("CmdlineEnter", {
        callback = function()
          local row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed cursor row
          local width = vim.api.nvim_win_get_width(0)
          vim.api.nvim_buf_set_extmark(0, cmdline_ns, row, 0, {
            virt_lines = {
              { { string.rep(" ", width), "CmdlineActiveLine" } },
            },
            virt_lines_above = false,
          })
        end,
      })

      vim.api.nvim_create_autocmd("CmdlineLeave", {
        callback = function()
          vim.api.nvim_buf_clear_namespace(0, cmdline_ns, 0, -1)
        end,
      })

      vim.api.nvim_set_hl(0, "CmdlineActiveLine", { bg = "#0d1133" })
    '';
  };

  notificatios = {
    plugins.notify = {
      enable = true;
      settings = {
        background_colour = "#ffffff";
        render = "compact";
        timeout = 500;
        stages.__raw = ''
          (function(direction)
            local stages_util = require("notify.stages.util")
            return {
              function(state)
                local next_height = state.message.height + 2
                local next_row = stages_util.available_slot(state.open_windows, next_height, direction)
                if not next_row then
                  return nil
                end
                return {
                  relative = "cursor",
                  anchor = "NW",
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
                  style = "minimal",
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
                  width = { 1, frequency = 2 },
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
          require("notify").dismiss({ silent = true })
        end,
      })
    '';
  };
in
lib.mkMerge [ notificatios cmdline ]
