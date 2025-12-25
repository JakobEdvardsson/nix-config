{ lib, ... }:
{
  imports = [
    (lib.custom.relativeToRoot "modules/host-spec.nix")
    (lib.custom.relativeToRoot "modules/common")
    (lib.custom.relativeToRoot "modules/users")
    (lib.custom.relativeToRoot "homelab")
  ];
}
