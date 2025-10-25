let
  commit-fstr = "%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%w(0,10,10)%n%C(white)%s%C(reset) %C(dim white)- %an (%ae)%C(reset)";
in
{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "master";
      user.name = "Levi van der Maas";
      user.useConfigOnly = true;
      advice.detachedHead = false;

      alias = {
        l = "log --graph --abbrev-commit --decorate --format=format:'${commit-fstr}'";
        graph = "log --graph --abbrev-commit --decorate --all --format=format:'${commit-fstr}'";

        about = "show --stat --format=format:'${commit-fstr}%n%b'";
        shortabout = "show --shortstat --format=format:'${commit-fstr}%n%b'";

        a = "add";
        c = "commit";
        d = "diff";
        ds = "diff --staged";
        s = "status";

        amend = "commit --amend";
        softmerge = "merge --no-ff --no-commit";
        unstage = "restore --staged";
      };
    };
  };
}
