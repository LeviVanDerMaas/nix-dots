{
  # NOTE: Prompt will not change in shell unless shell has been enabled *in home-manager config*
  # (e.g. `programs.bash.enable = true`)
  programs.starship.enable = true;
  
  programs.starship.settings = {
    directory = {
      truncation_length = 9;
    };

    git_status = {
       
      format = "([\\[$all_status$ahead_behind\\]]($style) )";
      staged = "[+](bold green)";
      ahead = "{[⇡$count](bold green)}";
      behind = "{[⇣$count](bold red)}";
      diverged = "{[⇡$ahead_count](bold green)[⇣$behind_count](bold red)}";
      renamed = "[»](bold red)";
      typechanged = "[T](bold red)";
      stashed = "[\\$](bold yellow)";
      heuristic = true;
    };

    nix_shell = {
      format = "via [$symbol$name $state]($style) ";
      impure_msg = "";
      pure_msg = "(PURE)";
      unknown_msg = "(PURITY UNCLEAR)";
    };
  };
}
