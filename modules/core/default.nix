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
    inputs.sops-nix.nixosModules.sops

    (map lib.custom.relativeToRoot [
      "modules/host-spec.nix"
      "homelab"
      "modules/core/services"
      "modules/users/primary"
      "modules/users/deploy.nix"
      "modules/optional"
    ])
    (lib.custom.scanPaths ./.)
  ];
}
