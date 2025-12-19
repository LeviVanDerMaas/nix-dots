{ lib, config, ... }:

let
  # Modify git aliases so that they use difft as a difftool
  aliasesWithDifft = lib.mapAttrs (
    let
      strIfDifft = lib.optionalString config.programs.difftastic.enable;
    in
    n: v:
      strIfDifft "-c diff.external=difft "
      + v
      + strIfDifft " --ext-diff"
  );
in
{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "master";
      user.name = "Levi van der Maas";
      user.useConfigOnly = true;
      advice.detachedHead = false;

      pretty.custom = "format:%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%w(0,10,10)%n%C(white)%s%C(reset) %C(dim white)- %an (%ae)%C(reset)%n%C(italic white)%b%C(reset)";
      alias = {
        a = "add";
        c = "commit";
        s = "status";

        amend = "commit --amend";
        softmerge = "merge --no-ff --no-commit";
        unstage = "restore --staged";

        setUserPersonal = "!git config user.name ='Levi van der Maas'; git config user.email ='levi.vdmaas@gmail.com'";
        setUserUni = "!git config user.name ='Levi van der Maas'; git config user.email ='l.a.vandermaas@student.tudelft.nl'";
      }
      // aliasesWithDifft {
        l = "log --graph --abbrev-commit --decorate --pretty=custom";
        graph = "log --graph --abbrev-commit --decorate --all --pretty=custom";

        about = "show --stat --pretty=custom";
        shortabout = "show --shortstat --pretty=custom";

        d = "diff";
        ds = "diff --staged";
      };
    };
  };
}
