{ lib, config, ... }:

let
  cfg = config.docker;
in
{
  options = {
    docker.enable = 
      lib.mkEnableOption "Docker module";
    docker.dockerGroupMembers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        DANGEROUS SETTING! USERS ADDED TO THIS GROUP WILL EFFECTIVELY
        BE ROOT EQUIVALENT THROUGH `docker run --privileged`!
        Users that will be made members of the docker group. Needed to
        access the docker socket as non-root user.'';
    };
  };

  config = {
    virtualisation.docker = {
      enable = true;
    };

    users.extraGroups.docker.members = cfg.dockerGroupMembers;
  };
}
