{ lib, ... }:
{
  imports = [
    (lib.custom.relativeToRoot "modules/host-spec.nix")
    (lib.custom.relativeToRoot "modules/core")
    (lib.custom.relativeToRoot "modules/users")
    (lib.custom.relativeToRoot "modules/optional")
    (lib.custom.relativeToRoot "homelab")
  ];
}
