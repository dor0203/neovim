{ pkgs, inputs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "noob-nvim";
      src = inputs.noob-nvim;
      doCheck = false;
    })
  ];

  keymaps = [
    {
      mode = "n";
      key = "<F7>";
      action = "<cmd>Noob<CR>";
      options.desc = "Toggle noob cheatsheet";
    }
  ];

  extraConfigLua = ''
    require('noob').setup({
        split = false,
    })
  '';
}
