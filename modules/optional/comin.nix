{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.customOption.comin;
in
{
  imports = [ inputs.comin.nixosModules.comin ];

  options.customOption.comin = {
    enable = lib.mkEnableOption "Enable comin, auto pulls config from Github";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      githubCominAccessToken = { };
    };

    services.comin = {
      enable = true;
      remotes = [
        {
          name = "origin";
          url = "https://github.com/jakobedvardsson/nix-config.git";
          branches.main.name = "main";
          auth.access_token_path = config.sops.secrets.githubCominAccessToken.path;
        }
      ];
    };
  };
}
