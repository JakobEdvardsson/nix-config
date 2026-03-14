# User config applicable to both nixos and darwin
{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  hostSpec = config.hostSpec;
  pubKeys = lib.filesystem.listFilesRecursive ./keys;
  towerPubKey = builtins.readFile ./keys/tower.pub;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  sopsHashedPasswordFile = config.sops.secrets."passwords/${hostSpec.username}".path;
in
{
  users.mutableUsers = false; # Only allow declarative credentials; Required for password to be set via sops during system activation!
  users.users.${hostSpec.username} = {
    name = hostSpec.username;
    home = "/home/${hostSpec.username}";
    isNormalUser = true;
    hashedPasswordFile = sopsHashedPasswordFile; # Comment out to disable password
    # password = lib.mkForce "nixos"; # Uncomment to set temporary password until sops passwords work
    shell = pkgs.fish; # default shell
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);

    extraGroups = lib.flatten [
      "wheel"
      (ifTheyExist [
        "media" # used for homelab
        "audio"
        "video"
        "docker"
        "git"
        "networkmanager"
        "scanner" # for print/scan"
        "lp" # for print/scan"
      ])
    ];
  };

  # No matter what environment we are in we want these tools
  programs.fish.enable = true;
  programs.git = {
    enable = true;
    config.init.defaultBranch = "main";
  };
  environment.systemPackages = with pkgs; [
    just
    rsync
    perf
    busybox
  ];

  # Import the user's personal/home configurations, unless the environment is minimal

  home-manager = {
    extraSpecialArgs = {
      inherit pkgs inputs;
      hostSpec = config.hostSpec;
    };
    users.${hostSpec.username}.imports = lib.flatten [
      (
        { config, ... }:
        import (lib.custom.relativeToRoot "home/${hostSpec.username}/${hostSpec.hostName}") {
          inherit
            pkgs
            inputs
            config
            lib
            hostSpec
            ;
        }
      )
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [ towerPubKey ];
}
