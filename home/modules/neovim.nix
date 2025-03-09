{ pkgs, lib, ... }:
let
  fromGitHub = ref: rev: repo:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = ref;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        ref = ref;
        rev = rev;
      };
    };
in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withPython3 = true;
    withNodeJs = true;
    extraLuaConfig = "	package.path = package.path .. \";${
         ../config/nvim
       }/lua/?.lua\"\n	dofile(\"${../config/nvim}/init.lua\")\n";
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-web-devicons
      lualine-nvim
      comment-nvim
      rainbow
      catppuccin-nvim
      plenary-nvim
      telescope-nvim
      nvim-cmp
      cmp_luasnip
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-cmdline-history
      luasnip
      friendly-snippets
      nvim-tree-lua
      barbar-nvim
      toggleterm-nvim
      vim-fugitive
      editorconfig-vim
      gitsigns-nvim
      nvim-treesitter.withAllGrammars
      auto-session
      vim-better-whitespace
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-dap-go
      nvim-window-picker
      promise-async
      nvim-ufo
    ];
    # install luanguage servers
    extraPackages = with pkgs; [
      ripgrep
      lua-language-server
      ruff
      pyright
      cmake-language-server
      tree-sitter
      clang-tools
      efm-langserver
      gopls
      black
      shellcheck
      nodePackages.bash-language-server
      shfmt
      nixd
      nixfmt
    ];
  };
}
