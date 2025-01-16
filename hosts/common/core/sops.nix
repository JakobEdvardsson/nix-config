# hosts level sops. see home/[user]/common/optional/sops.nix for home/user level

{
  pkgs,
  config,
  lib,
  ...
}:
let
  secretsFile = lib.custom.relativeToRoot "secrets.yaml";
in
{
  #the import for inputs.sops-nix.nixosModules.sops is handled in hosts/common/core/default.nix so that it can be dynamically input according to the platform

  sops = {
    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    # secrets will be output to /run/secrets
    # e.g. /run/secrets/msmtp-password
    # secrets required for user creation are handled in respective ./users/<username>.nix files
    # because they will be output to /run/secrets-for-users and only when the user is assigned to a host.

    # For home-manager a separate age key is used to decrypt secrets and must be placed onto the host. This is because
    # the user doesn't have read permission for the ssh service private key. However, we can bootstrap the age key from
    # the secrets decrypted by the host key, which allows home-manager secrets to work without manually copying over
    # the age key.
    secrets = {
      # These age keys are are unique for the user on each host and are generated on their own (i.e. they are not derived
      # from an ssh key).
      #TODO: fix
      /*
        "keys/age/${config.hostSpec.username}_${config.networking.hostName}" = {
          owner = config.users.users.${config.hostSpec.username}.name;
          inherit (config.users.users.${config.hostSpec.username}) group;
          # We need to ensure the entire directory structure is that of the user...
          path = "${config.hostSpec.home}/.config/sops/age/keys.txt";
        };
      */

      # extract password/username to /run/secrets-for-users/ so it can be used to create the user
      "passwords/${config.hostSpec.username}".neededForUsers = true;
      "private_keys/jakobe" = { };

    };

  };
  # The containing folders are created as root and if this is the first ~/.config/ entry,
  # the ownership is busted and home-manager can't target because it can't write into .config...
  # FIXME:(sops) We might not need this depending on how https://github.com/Mic92/sops-nix/issues/381 is fixed
  system.activationScripts.sopsSetAgeKeyOwnership =
    let
      ageFolder = "${config.hostSpec.home}/.config/sops/age";
      user = config.users.users.${config.hostSpec.username}.name;
      group = config.users.users.${config.hostSpec.username}.group;
    in
    ''
      mkdir -p ${ageFolder} || true
      chown -R ${user}:${group} ${config.hostSpec.home}/.config
    '';
}
