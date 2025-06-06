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

3. Import a disko disk layout in `flake.nix`:

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

2. Clone config repo:

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

4. Copy the private key to local machine:

```bash
nix-shell -p ssh-to-age --run 'sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key -o ~/.config/sops/age/keys.txt'
nix-shell -p age --run 'age-keygen -y ~/.config/sops/age/keys.txt'  # Confirm it matches
```

5. Update secrets:

```bash
sops updatekeys secrets.yaml
```

6. **Commit and push changes**

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

---

### Optional: Remote Deploy via `deploy` User

Once a machine is up and running, you can manage it remotely using the restricted `deploy` user.

#### 1. Enable `deploy` User

In host configuration (`hosts/nixos/<hostname>/default.nix` or similar):

```nix
customOption.deploy.enable = true;
```

#### 2. Add Public Key

Add SSH public key to `hosts/common/users/primary/keys` so they are included in deploy's authorizedKeys.

#### 3. Rebuild to apply changes

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

#### 4. Deploy Remotely

From management machine, deploy updates with:

```bash
nixos-rebuild switch \
  --flake .#<hostname> \
  --target-host deploy@<hostname> \
  --use-remote-sudo
```


---

### Tailscale

Start the Tailscale daemon and authenticate:

```bash
sudo tailscale up --accept-routes

