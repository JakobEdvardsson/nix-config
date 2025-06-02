## NixOS Install Guide

### Prepare Host Configuration

1. Create a new host config:

```bash
mkdir -p hosts/nixos/<hostname>
```

2. Create a matching home-manager config:

```bash
mkdir -p home/jakobe/<hostname>
```

3. Import a disko disk layout in your `flake.nix`:

```nix
inputs.disko.nixosModules.disko
(lib.custom.relativeToRoot "hosts/common/disks/btrfs.nix")
{
  _module.args = {
    disk = "/dev/nvme0n1";
  };
}
```

---

### Install NixOS

1. Boot into a NixOS installer ISO.

2. Clone your config repo:

```bash
nix-shell -p git vim disko
git clone https://github.com/jakobedvardsson/nix-config
cd nix-config
```

3. Temporarily enable password login by editing `hosts/common/users/primary/default.nix`:

```nix
#hashedPasswordFile = sopsHashedPasswordFile;  # Comment out
password = lib.mkForce "nixos";               # Add this temporarily
```

4. Generate `hardware.nix`:

```bash
nixos-generate-config --show-hardware-config --no-filesystems > hosts/nixos/<hostname>/hardware.nix
```

5. Partition and install:

```bash
nix-shell -p disko
sudo disko --mode disko --flake .#<hostname>
sudo nixos-install --no-channel-copy --flake .#<hostname>
```

---

### SOPS Key Setup

1. SSH into the new machine.

2. Extract the age identity from the host SSH key:

```bash
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

3. Add that public key to `.sops.yaml` as a new host entry.

4. Copy the private key to your local machine:

```bash
nix-shell -p ssh-to-age --run 'sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key -o ~/.config/sops/age/keys.txt'
nix-shell -p age --run 'age-keygen -y ~/.config/sops/age/keys.txt'  # Confirm it matches
```

5. Update secrets:

```bash
sops updatekeys secrets.yaml
```

6. Commit and push your changes.

---

### Final Boot

1. Back on the new machine:

```bash
cd && git clone https://github.com/jakobedvardsson/nix-config
cd nix-config
sudo nixos-rebuild boot --flake .#<hostname>
reboot
```

2. **Revert the temporary password override**:
   Edit `hosts/common/users/primary/default.nix` and undo the temporary password setting:

```nix
# Remove or comment this:
password = lib.mkForce "nixos";

# Restore this:
hashedPasswordFile = sopsHashedPasswordFile;
```

3. Apply the change:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

