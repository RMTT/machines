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
    { name = "zdharma-continuum/fast-syntax-highlighting"; }
    { name = "zsh-users/zsh-completions"; }
    {
      name = "plugins/extract";
      tags = [ "from:oh-my-zsh" ];
    }
    {
      name = "plugins/git";
      tags = [ "from:oh-my-zsh" ];
    }
		{ name = "jeffreytse/zsh-vi-mode"; }
  ];
  programs.zsh.defaultKeymap = "viins";

  # startship configuration
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character.success_symbol = "[>](bold green)";
      character.error_symbol = "[>](bold red)";
			character.vimcmd_symbol = "[<](bold green)";
			character.vimcmd_replace_one_symbol = "[<](bold purple)";
			character.vimcmd_replace_symbol = "[<](bold purple)";
			character.vimcmd_visual_symbol = "[<](bold yellow)";
    };
  };
}
