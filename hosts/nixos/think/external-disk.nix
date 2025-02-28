{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  fileSystems.${config.homelab.mounts.slow} = {
    device = "/dev/disk/by-uuid/1e3795b5-c1e2-4c6d-9663-1600b4efa33e";
    options = [
      "defaults"
      "noatime" # Avoids writing access times, improves performance
      "errors=remount-ro" # Remount as read-only on failure
      "x-mount.mkdir" # Creates the mount directory if missing
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
    fsType = "ext4";
  };

  fileSystems.${config.homelab.mounts.fast} = {
    device = "/dev/disk/by-uuid/e19d961a-c436-452d-8735-2be06a7e296d";
    options = [
      "defaults"
      "noatime" # Avoids writing access times, improves performance
      "errors=remount-ro" # Remount as read-only on failure
      "x-mount.mkdir" # Creates the mount directory if missing
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
    fsType = "ext4";
  };

}
