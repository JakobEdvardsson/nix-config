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
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  sopsHashedPasswordFile = config.sops.secrets."passwords/${hostSpec.username}".path;

in
{
  users.mutableUsers = false; # Only allow declarative credentials; Required for password to be set via sops during system activation!
  users.users.${hostSpec.username} = {
    name = hostSpec.username;
    home = "/home/${hostSpec.username}";
    isNormalUser = true;
    hashedPasswordFile = sopsHashedPasswordFile; # Blank if sops is not working.
    # password = lib.mkForce "nixos"; # This gets overridden if sops is working; it is only used with nixos-installer
    shell = pkgs.fish; # default shell
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);

    extraGroups = lib.flatten [
      "wheel"
      (ifTheyExist [
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

  # Create ssh sockets directory for controlpaths when homemanager not loaded (i.e. isMinimal)
  systemd.tmpfiles.rules =
    let
      user = config.users.users.${hostSpec.username}.name;
      group = config.users.users.${hostSpec.username}.group;
    in
    [ "d /home/${hostSpec.username}/.ssh/sockets 0750 ${user} ${group} -" ];

  # No matter what environment we are in we want these tools
  programs.fish.enable = true;
  programs.git.enable = true;
  environment.systemPackages = [
    pkgs.just
    pkgs.rsync
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
        import (lib.custom.relativeToRoot "home/${hostSpec.username}/${hostSpec.hostName}.nix") {
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

  # root's ssh key are mainly used for remote deployment, borg, and some other specific ops
  users.users.root = {
    # TODO: look at this
    shell = pkgs.zsh;
    hashedPasswordFile = config.users.users.${hostSpec.username}.hashedPasswordFile;
    password = lib.mkForce config.users.users.${hostSpec.username}.password; # This gets overridden if sops is working; it is only used if the hostSpec.hostName == "iso"
    # root's ssh keys are mainly used for remote deployment.
    openssh.authorizedKeys.keys = config.users.users.${hostSpec.username}.openssh.authorizedKeys.keys;
  };

  home-manager.users.root = lib.optionalAttrs (!hostSpec.isMinimal) {
    home.stateVersion = "23.05"; # Avoid error
    programs.zsh = {
      enable = true;
      plugins = [
        {
          name = "powerlevel10k-config";
          src = lib.custom.relativeToRoot "home/${hostSpec.username}/common/core/zsh/p10k";
          file = "p10k.zsh";
        }
      ];
    };
  };

}
