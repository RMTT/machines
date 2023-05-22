{ pkgs-unstable, ... }:
let configPath = ../config/nvim;
in {
  xdg.configFile.nvim.source = configPath;
  xdg.configFile.nvim.recursive = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    package = pkgs-unstable.neovim-unwrapped;
    withPython3 = true;
    withNodeJs = true;
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
    # install luanguage servers
    extraPackages = with pkgs-unstable; [
      sumneko-lua-language-server
      nodePackages.pyright
      nil
      cmake-language-server
      tree-sitter
      clang-tools
      efm-langserver
    ];
  };
}
