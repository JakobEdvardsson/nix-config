{ pkgs, ... }:
{
  hardware.keyboard.zsa.enable = true;
  hardware.keyboard.qmk.enable = true;
  environment.systemPackages = with pkgs; [
    keymapp
    qmk
  ];
}
