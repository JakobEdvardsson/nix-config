- Create new host under hosts/nixos/<hostname>
- Create new home under home/jakobe/<hostname>

- Put "admin" age sops key in ~/.config/sops/age/keys.txt
- Sudo nixos-rebuild switch --flake .#<hostname>

- Create key derived from host ssh key

```bash
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age' # Get age key from host ssh key
```

- Add to .sops.yaml
- Remove "admin" key from ~/.config/sops/age/keys.txt
- Update the keys for sops

```bash
sops updatekeys # Update sops to also use the new key
```
