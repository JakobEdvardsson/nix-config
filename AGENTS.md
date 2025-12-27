# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` defines inputs, `nixosConfigurations`, and the formatter/devshell.
- `hosts/<hostname>/` contains machine-specific NixOS configs (e.g., `hosts/think/`).
- `modules/` holds reusable NixOS modules and shared options.
- `home/` contains home-manager configs by user and host.
- `homelab/` collects service modules and reverse-proxy options.
- `lib/` provides helper functions used across the flake.
- `secrets.yaml` stores SOPS-managed secrets; `docs/` and `README.md` cover setup.

## Build, Test, and Development Commands
- `nix develop` opens the dev shell with formatters and linters.
- `nix fmt` formats all Nix files via `nixfmt-tree`.
- `statix check` runs Nix linting (available in the dev shell).
- `nix build .#nixosConfigurations.think.config.system.build.toplevel` evaluates the Think host build.

## Inspection & Debugging
- Use `nix repl` with `:lf .` to inspect options and module outputs.

## Coding Style & Naming Conventions
- Use 2-space indentation in Nix files and keep attribute sets tidy.
- Prefer `nixfmt-rfc-style` formatting (via `nix fmt`).
- Name host directories as `hosts/<hostname>` and services as `homelab/services/<category>/<service>.nix`.
- Keep options under logical namespaces (for example, `homelab.services.<service>`).

## Testing Guidelines
- Primary evaluation check:

```bash
nix build .#nixosConfigurations.think.config.system.build.toplevel
```

- Run this at the end of changes; if it fails, fix the errors before finishing.
- No dedicated unit test framework is set up; rely on Nix evaluation and targeted rebuilds.

## Commit & Pull Request Guidelines
- Do not use `git` in this environment; capture change summaries in your PR description outside the repo.
- Include what changed, which hosts/services are affected, and any required manual steps.

## Security & Configuration Tips
- Keep secrets in `secrets.yaml` with SOPS; never add plaintext secrets to the repo.
- When adding new hosts, follow the install steps in `README.md` and update SOPS keys as needed.
