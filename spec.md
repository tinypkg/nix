# Spec: tinypkg Nix packages

## Objective

Create a public `tinypkg/nix` flake that packages every application currently
maintained in `tinypkg/aur`. Users can install the applications with Nix on any
Linux distribution without depending on AUR, while Arch users retain a clearly
documented AUR path.

## Tech Stack

- Nix flakes, flake-parts, and nixpkgs `nixos-unstable`
- Nix derivations for prebuilt archives, Debian packages, AppImages, and Python wheels
- GitHub Actions for flake evaluation and representative builds
- Shell scripts for repository checks and package update assistance

## Commands

- Show packages: `nix flake show github:tinypkg/nix`
- Check the flake: `nix flake check --all-systems`
- Build one package: `nix build github:tinypkg/nix#<package>`
- Install one package: `nix profile install github:tinypkg/nix#<package>`
- Run repository checks: `nix develop --command ./scripts/check.sh`

## Project Structure

- `flake.nix` — flake-parts package, check, formatter, and development-shell outputs
- `packages/<name>/package.nix` — isolated build metadata per application
- `packages/<name>/source.json` — isolated version, source, hash, and update policy
- `lib/` — shared builders for recurring binary formats
- `scripts/` — validation and maintenance helpers
- `tests/` — structural repository checks
- `tasks/` — implementation plan and completion checklist
- `.github/workflows/` — continuous evaluation and representative builds

## Code Style

Nix files use two-space indentation, one attribute per line, kebab-case package
names matching their AUR counterparts, and explicit platform declarations.

```nix
{
  lib,
  mkBinary,
}:

mkBinary {
  pname = "example";
  version = "1.2.3";
  meta = {
    description = "Example application";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
```

## Testing Strategy

- Assert that every AUR package has a corresponding flake package.
- Format-check all Nix sources.
- Evaluate all supported package attributes on their native systems.
- Build representative packages from each format: archive CLI, Debian desktop,
  AppImage, and Python wheel.
- Validate the README package table against the exported package names.

## Boundaries

- Always: pin nixpkgs, use fixed-output hashes, preserve upstream licenses, and
  run checks before pushing.
- Ask first: omit an AUR package, rename the GitHub repository, or introduce a
  non-nixpkgs service dependency.
- Never: commit credentials, silently use mutable source URLs without hashes,
  or claim unsupported platforms.

## Success Criteria

- All 40 current AUR package names are exported by the flake.
- `nix flake check` evaluates successfully in a clean Nix container.
- At least one CLI archive and one GUI package build successfully on x86_64 Linux.
- README lists every package with description and upstream URL.
- README documents NixOS, Home Manager, `nix profile`, `nix run`, flake setup,
  and Arch/AUR prerequisite and installation commands.
- The repository is committed and pushed to public `github.com/tinypkg/nix`.

## Open Questions

None. Repository owner and local path were confirmed by the user; package scope
is the complete current `tinypkg/aur` collection.
