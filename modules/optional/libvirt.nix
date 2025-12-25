{
  pkgs,
  lib,
  config,
  ...
}:
# FIXME:(qemu) Should we merge all virtualization stuff, like podman?
let
  cfg = config.customOption.libvirt;
in
{
  options.customOption.libvirt = {
    enable = lib.mkEnableOption "Enable libvirt";
  };

  config = lib.mkIf cfg.enable {
    # FIXME:(qemu) Revisit if required
    boot.kernelModules = [ "vfio-pci" ];

    # This allows yubikey direction into a QEMU image https://github.com/NixOS/nixpkgs/issues/39618
    virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        # FIXME:(qemu) Is this necessary?
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        # FIXME:(qemu) What is this?
        swtpm.enable = true;
        #      ovmf = {
        #        enable = true;
        #        # FIXME:(qemu) This is from nixos.wiki but is super slow as it manually builds. Should see if it's required
        #        # It's mostly for allowing secure boot, but qemu may already do it
        #        packages = [
        #          (pkgs.OVMF.override {
        #            secureBoot = true;
        #            tpmSupport = true;
        #          }).fd
        #        ];
        #      };
      };
    };

    # Need to add [File (in the menu bar) -> Add connection] when start for the first time
    programs.virt-manager.enable = true;

    # FIXME:(qemu) Comments from ryan4yin, revisit
    environment.systemPackages = [
      # QEMU/KVM(HostCpuOnly), provides:
      #   qemu-storage-daemon qemu-edid qemu-ga
      #   qemu-pr-helper qemu-nbd elf2dmp qemu-img qemu-io
      #   qemu-kvm qemu-system-x86_64 qemu-system-aarch64 qemu-system-i386
      pkgs.qemu_kvm

      # Install QEMU(other architectures), provides:
      #   ......
      #   qemu-loongarch64 qemu-system-loongarch64
      #   qemu-riscv64 qemu-system-riscv64 qemu-riscv32  qemu-system-riscv32
      #   qemu-system-arm qemu-arm qemu-armeb qemu-system-aarch64 qemu-aarch64 qemu-aarch64_be
      #   qemu-system-xtensa qemu-xtensa qemu-system-xtensaeb qemu-xtensaeb
      #   ......
      pkgs.qemu
    ];

    users.users.${config.hostSpec.username} = {
      extraGroups = [ "libvirtd" ];
    };
  };
}
