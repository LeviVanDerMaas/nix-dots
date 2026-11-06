{ inputs, ... }:

{
  imports = [ inputs.leviNeovimConfig.homeManagerModules.default ];

  config = {
    programs.leviNeovimConfig = {
      enable = true;
      useHMPkgs = true;
    };
    # Add a shell function that opens man pages in neovim
    programs.bash.initExtra = /* bash */ ''
      viman() { nvim +"Man $* | only"; }
    '';
  };
}
