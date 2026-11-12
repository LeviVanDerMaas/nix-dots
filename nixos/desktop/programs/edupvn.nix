{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eduvpn-client
  ];

  networking.networkmanager = {
    # edupvn depends on networkmanager and my uni needs openvpn.
    enable = true;
    plugins = with pkgs; [ networkmanager-openvpn ];
  };
}
