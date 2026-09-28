{ inputs, ... }:

{
  imports = [ inputs.levisNeovimConfig.homeManagerModules.default ];

  config = {
    programs.levisNeovimConfig.enable = true;
    # Add a shell function that opens man pages in neovim
    programs.bash.initExtra = /* bash */ ''
      viman() { nvim +"Man $* | only"; }
    '';
  };
}
