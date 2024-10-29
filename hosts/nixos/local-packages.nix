{ pkgs, pkgs-stable, ... }:
{

  environment.systemPackages =
    (with pkgs-stable; [
      # Stable
    ])
    ++ (with pkgs; [
      # Unstable

    ]);

}
