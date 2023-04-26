{ pkgs-unstable, ... }:
let configPath = ../config/nvim;
in {
  xdg.configFile.nvim.source = configPath;
  xdg.configFile.nvim.recursive = true;

  # install luanguage servers
  home.packages = with pkgs-unstable; [
    sumneko-lua-language-server
    nodePackages.pyright
    nil
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    package = pkgs-unstable.neovim-unwrapped;
    withPython3 = true;
    withNodeJs = false;
    plugins = with pkgs-unstable.vimPlugins; [
      nvim-lspconfig
      nvim-web-devicons
      lualine-nvim
      rainbow
      tokyonight-nvim
      plenary-nvim
      telescope-nvim
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      nvim-cmp
      luasnip
      cmp_luasnip
      nvim-tree-lua
      barbar-nvim
      FTerm-nvim
      vim-fugitive
      editorconfig-vim
      gitsigns-nvim
      nvim-treesitter
      auto-session
      vim-better-whitespace
      neodev-nvim
    ];
  };
}
