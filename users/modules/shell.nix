{ ... }: {

  # bash configuration
  programs.bash.enable = true;

  # zsh configuration
  programs.zsh.enable = true;
  programs.zsh.initExtraFirst = ''
    autoload -Uz add-zsh-hook
    auto_rehash () {
        rehash
    }
    add-zsh-hook precmd auto_rehash
  '';
  programs.zsh.shellAliases = { "ls" = "exa"; };
  programs.zsh.zplug.enable = true;
  programs.zsh.zplug.plugins = [
    { name = "zsh-users/zsh-autosuggestions"; }
    { name = "zsh-users/zsh-syntax-highlighting"; }
    { name = "zsh-users/zsh-completions"; }
    {
      name = "plugins/extract";
      tags = [ "from:oh-my-zsh" ];
    }
    {
      name = "plugins/git";
      tags = [ "from:oh-my-zsh" ];
    }
  ];
  programs.zsh.defaultKeymap = "emacs";

  # startship configuration
  programs.starship = {
    enable = true;
    settings = { add_newline = false; };
  };
}
