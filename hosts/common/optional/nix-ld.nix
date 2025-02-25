{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.customOption.nix-ld;
in
{

  options.customOption.nix-ld = {
    enable = lib.mkEnableOption "Enable nix-ld";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
    ];
  };
}
