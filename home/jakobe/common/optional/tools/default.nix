{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)
      # Development
      tokei

      # Device imaging
      rpi-imager
      #etcher #was disabled in nixpkgs due to dependency on insecure version of Electron

      # Productivity
      drawio
      grimblast
      libreoffice

      # Privacy
      #veracrypt
      #keepassxc

      # Web sites
      zola

      # Media production
      obs-studio
      # VM and RDP
      # remmina
      ;
  };
  #Disabled for now. grimblast
  #  services.flameshot = {
  #      enable = true;
  #     package = flameshotGrim;
  #  };
}
