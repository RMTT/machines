{ config, ... }: {

  # bash configuration
  programs.bash.enable = true;

  # zsh configuration
  programs.zsh.enable = true;
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
  programs.zsh.localVariables = {
    SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
  };
  programs.zsh.initContent = ''
    if command -v kubectl &> /dev/null
    then
    	source <(kubectl completion zsh)
    fi

    if [ -e /opt/homebrew ]
    then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
                    		'';

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

      package.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = false;
    };
  };
}
