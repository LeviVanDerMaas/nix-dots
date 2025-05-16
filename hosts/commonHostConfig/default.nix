{ lib, ... }:

{
    options.commonHostConfig = {
        hostType = lib.mkOption {
            type = lib.types.enum ["desktop", "laptop"]
        }''
            Set some settings depending on the type of host.
        '';

    };
}
