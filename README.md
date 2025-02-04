- Create new host under hosts/nixos/<hostname>
- Create new home under home/jakobe/<hostname>

#- Put "admin" age sops key in ~/.config/sops/age/keys.txt
#- Sudo nixos-rebuild switch --flake .#<hostname>

- Install nixos on the new host
- Clone repo

```bash
nix-shell -p git
git clone https://github.com/jakobedvardsson/nix-config
cd nix-config
```

- edit hosts/common/users/primary/default.nix

```nix
#hashedPasswordFile = sopsHashedPasswordFile; # Comment out to disable password
password = lib.mkForce "nixos"; # Uncomment to set temporary password until sops passwords work
```

- update hardware.nix && build system

```bash
nixos-generate-config --show-hardware-config > ~/nix-config/hosts/nixos/think/hardware.nix
sudo nixos-rebuild boot --flake .#<hostname>
```

- From another machine ssh into the new host
- Create key derived from host ssh key and add it to

```bash
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age' # Get age key from host ssh key
nix-shell -p ssh-to-age --run 'sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key -o ~/.config/sops/age/keys.txt' # Get private-key to keys.txt
nix-shell -p age --run 'age-keygen -y ~/.config/sops/age/keys.txt' # Verify same public key
```

- From the host, add the public age key to .sops.yaml as a new host
- Update the keys for sops

```bash
sops updatekeys secrets.yaml # Update sops to also use the new key
```
