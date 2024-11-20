{ pkgs, pkgs-stable, ... }:
{

  environment.systemPackages =
    (with pkgs-stable; [
      # Stable
      git
      gh
      vim
      neovim

      # Terminal
      neovim
      lazygit
      ripgrep
      fd
      zoxide
      oh-my-posh
      kitty
      lsd
      starship
      yazi

      # System Packages
      curl
      cpufrequtils
      duf
      eza
      ffmpeg
      killall
      openssl # required by Rainbow borders
      pciutils
      wget
      tree
      usbutils
      radeontop
    ])
    ++ (with pkgs; [
      # Unstable

    ]);

}
