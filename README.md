# Setup for new host

- Create new host under hosts/nixos/<hostname>
- Create new home under home/jakobe/<hostname>

- Import disko disk layout

```nix
#example
inputs.disko.nixosModules.disko
(lib.custom.relativeToRoot "hosts/common/disks/btrfs.nix")
{
  _module.args = {
    disk = "/dev/nvme0n1";
  };
}
```

- Boot from a NixOS installer
- Clone repo

```bash
nix-shell -p git vim disko
cd && git clone https://github.com/jakobedvardsson/nix-config
cd nix-config
```

- Edit hosts/common/users/primary/default.nix to temporary set a password

```nix
#hashedPasswordFile = sopsHashedPasswordFile; # Comment out to disable password
password = lib.mkForce "nixos"; # Uncomment to set temporary password until sops passwords work
```

- Add hardware.nix

```bash
nixos-generate-config --show-hardware-config --no-filesystems > ~/nix-config/hosts/nixos/<hostname>/hardware.nix
```

- Installation

```bash
nix-shell -p disko
sudo disko --mode disko --flake .#name
sudo nixos-install --no-channel-copy --flake .#name
```

- From remote machine, ssh into the new machine
- Create key derived from host ssh key

```bash
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age' # Get age key from host ssh key (add to .sops.yaml as a new host)
nix-shell -p ssh-to-age --run 'sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key -o ~/.config/sops/age/keys.txt' # Get private-key to keys.txt
nix-shell -p age --run 'age-keygen -y ~/.config/sops/age/keys.txt' # Verify same public key
```

- On the remote machine, add the public age key to .sops.yaml as a new host
- Update the keys for sops

```bash
sops updatekeys secrets.yaml # Update sops to also use the new key
```

- Commit and push changed

- On the new machine, clone repo

```bash
cd && git clone https://github.com/jakobedvardsson/nix-config
cd nix-config
```

- Build the system

```bash
sudo nixos-rebuild boot --flake .#<hostname>
reboot
```
