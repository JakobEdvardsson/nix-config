# home level sops. see hosts/common/optional/sops.nix for hosts level
{ inputs, config, lib, ... }:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  secretsFilePath = "${secretsDirectory}/secrets.yaml";
  homeDirectory = config.home.homeDirectory;
in {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  sops = {
    # This is the location of the host specific age-key for ta and will to have been extracted to this location via hosts/common/core/sops.nix on the host
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretsFilePath}";
    validateSopsFiles = false;

    # Linux: Exists in $XDG_RUNTIME_DIR/id_foo
    # Darwin: Exists in $(getconf DARWIN_USER_TEMP_DIR)
    #   ex: /var/folders/pp/t8_sr4ln0qv5879cp3trt1b00000gn/T/id_foo
    secrets = {
      #placeholder for tokens that I haven't gotten to yet
      #"tokens/foo" = {
      #};
    };
  };
}
