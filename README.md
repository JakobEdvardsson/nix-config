# Setup for new host

- Create new host under hosts/nixos/<hostname>
- Create new home under home/jakobe/<hostname>

- Import disko disk layout

```nix
  imports = [ ./disko-config.nix ];
  disko.devices.disk.main.device = "/dev/<disk>";
```

- Boot from a NixOS installer
- Clone repo

```bash
nix-shell -p git
cd ~ && git clone https://github.com/jakobedvardsson/nix-config
cd nix-config
```

- Edit hosts/common/users/primary/default.nix to temporary set a password

```nix
#hashedPasswordFile = sopsHashedPasswordFile; # Comment out to disable password
password = lib.mkForce "nixos"; # Uncomment to set temporary password until sops passwords work
```

sudo nix run 'github:nix-community/disko/latest#disko-install' -- --flake '.#<hostname>'

- Update hardware.nix && build system

```bash
nixos-generate-config --show-hardware-config > ~/nix-config/hosts/nixos/<hostname>/hardware.nix
sudo nixos-rebuild boot --flake .#<hostname>
```

- From remote machine, ssh into the new machine
- Create key derived from host ssh key and add it to ~/.config/sops/age/keys.txt

```bash
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age' # Get age key from host ssh key
nix-shell -p ssh-to-age --run 'sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key -o ~/.config/sops/age/keys.txt' # Get private-key to keys.txt
nix-shell -p age --run 'age-keygen -y ~/.config/sops/age/keys.txt' # Verify same public key
```

- From the remote machine, add the public age key to .sops.yaml as a new host
- Update the keys for sops

```bash
sops updatekeys secrets.yaml # Update sops to also use the new key
```
