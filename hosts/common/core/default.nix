{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = lib.flatten [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops

    (map lib.custom.relativeToRoot [
      "modules/nixos"
      "homelab"
      "hosts/common/core/services"
      "hosts/common/users/primary"
      "hosts/common/optional"
    ])
    (lib.custom.scanPaths ./.)
  ];
}
