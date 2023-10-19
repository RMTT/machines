{ pkgs, lib, ... }:
let
  configPath = ../config/nvim;

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
  xdg.configFile.nvim.source = configPath;
  xdg.configFile.nvim.recursive = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    package = pkgs.neovim-unwrapped;
    withPython3 = true;
    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [
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
      nvim-treesitter.withAllGrammars
      auto-session
      vim-better-whitespace
      neodev-nvim
      (fromGitHub "main" "65bbc52c27b0cd4b29976fe03be73cc943357528"
        "s1n7ax/nvim-window-picker")
      (fromGitHub "master" "e30e3de6c791a05cdc08f5346c9be56adf17f1fe"
        "cappyzawa/starlark.vim")
      (fromGitHub "master" "bafa8feb15066d58a9de9a52719906343fb3af73"
        "carvel-dev/ytt.vim")
    ];
    # install luanguage servers
    extraPackages = with pkgs; [
      lua-language-server
      nodePackages.pyright
      nil
      cmake-language-server
      tree-sitter
      clang-tools
      efm-langserver
      gopls
      black
      shellcheck
      nodePackages.bash-language-server
    ];
  };
}
