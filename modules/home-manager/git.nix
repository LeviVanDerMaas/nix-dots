{
  programs.git = {
    enable = true;
    difftastic.enable = true;
    aliases = {
      l = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n          %C(white)%s%C(reset) %C(dim white)- %an (%ae)%C(reset)'";
      graph = "log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n          %C(white)%s%C(reset) %C(dim white)- %an (%ae)%C(reset)'";
      a = "add";
      c = "commit";
      d = "diff";
      s = "status";
    };
    extraConfig = {
      init.defaultBranch = "master";
      user.useConfigOnly = true;
    };
  };
}
