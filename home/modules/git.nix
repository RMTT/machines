{ ... }: {
  programs.git = {
    enable = true;
    ignores = [ ".envrc" ".direnv" "compile_commands.json" ".cache" ];
    userName = "RMT";
    userEmail = "d.rong@outlook.com";
    signing = {
      signByDefault = true;
      key = "d.rong@outlook.com";
    };
    extraConfig = {
      init.defaultBranch = "main";
      credential."https://github.com".helper =
        "!/usr/bin/env gh auth git-credential";
      credential."https://gist.github.com".helper =
        "!/usr/bin/env gh auth git-credential";
    };
  };
}
