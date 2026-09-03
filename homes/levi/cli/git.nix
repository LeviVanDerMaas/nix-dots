{ lib, config, ... }:

let
  # Modify git aliases so that they use difft as a difftool
  aliasesWithDifft = aliases:
    if config.programs.difftastic.enable then
      lib.mapAttrs (n: v: "-c diff.external=difft " + v + " --ext-diff") aliases
    else
      aliases;

  customPretty = full: 
    let
      extraInfo = "%C(dim white)Author:       %an (%ae)%C(reset)%n%C(dim white)AuthorDate:   %aD%C(reset)%n%C(dim white)Comitter:     %cn (%ce)%C(reset)%n%C(dim white)ComitterDate: %cD%C(reset)%n%n";
    in
    "format:%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%w(0,10,10)%n${lib.optionalString full extraInfo}%C(white)%s%C(reset)${lib.optionalString (!full) "%C(dim white) - %an (%ae)%C(reset)"}%n%C(italic white)%+b%C(reset)";
in
{
  programs.git = {
    enable = true;
    signing.format = null; # Legacy behaviour was pgp
    settings = {
      init.defaultBranch = "main";
      user.name = "Levi van der Maas";
      user.useConfigOnly = true;
      advice.detachedHead = false;

      # `LESS=FRX less` is what happens if LESS is unset; set explicitly to "merge"
      # custom less settings with default git behaviour.
      core.pager = "less -FRX"; 
      pretty.custom = customPretty false;
      pretty.customFull = customPretty true;

      alias = {
        a = "add";
        c = "commit";
        s = "status";

        amend = "commit --amend";
        recommit = "commit --amend --date=now";
        softmerge = "merge --no-ff --no-commit";
        unstage = "restore --staged";

        setUserPersonal = "!git config user.name 'Levi van der Maas'; git config user.email 'levi.vdmaas@gmail.com'";
        setUserUni = "!git config user.name 'Levi van der Maas'; git config user.email 'l.a.vandermaas@student.tudelft.nl'";
      }
      // aliasesWithDifft rec {
        l = "log --graph --abbrev-commit --decorate --pretty=custom";
        lf = "log --graph --abbrev-commit --decorate --pretty=customFull";
        graph = "${l} --exclude=refs/stash --all";
        graphf = "${lf} --exclude=refs/stash --all";

        about = "show --stat --pretty=custom";
        aboutf = "show --stat --pretty=customFull";
        shortabout = "show --shortstat --pretty=custom";
        shortaboutf = "show --shortstat --pretty=customFull";

        d = "diff";
        difft = "diff";
        ds = "diff --staged";
        dh = "diff HEAD";
      };
    };
  };
}
