{ pkgs, ... }:

{
  # services.openssh.enable = true; # Enable openSSH daemon.
  environment.systemPackages = with pkgs; [ openssh ];
}
