# tinypkg Nix packages

[**English**](README.md) | [简体中文](README.zh-CN.md)

[![Check](https://github.com/tinypkg/nix/actions/workflows/check.yml/badge.svg)](https://github.com/tinypkg/nix/actions/workflows/check.yml)
[![Update packages](https://github.com/tinypkg/nix/actions/workflows/update.yml/badge.svg)](https://github.com/tinypkg/nix/actions/workflows/update.yml)

`tinypkg/nix` provides reproducible Nix packages for the prebuilt Linux
applications maintained in [tinypkg/aur](https://github.com/tinypkg/aur). The
packages download upstream release artifacts, verify fixed hashes, unpack them,
and patch runtime library paths where required. They do not compile the
applications from source.

## Install Nix

### Omarchy and Arch Linux

Install the distribution package, initialize the store, and start the daemon:

```bash
sudo pacman -S nix
sudo nix-store --init
sudo systemctl enable --now nix-daemon.service
```

Add these settings to `/etc/nix/nix.conf`:

```ini
build-users-group = nixbld
experimental-features = nix-command flakes
```

Restart the daemon after editing the file:

```bash
sudo systemctl restart nix-daemon.service
nix --version
```

The `nixbld` group contains restricted build accounts. Your login user should
not be added to it.

### Other Linux distributions

Use the official multi-user installer:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Open a new shell after installation and enable `nix-command` and `flakes` in
`/etc/nix/nix.conf` if the installer has not already enabled them.

## Use this repository

List the exported packages:

```bash
nix flake show github:tinypkg/nix
```

Install a package into your user profile:

```bash
nix profile install github:tinypkg/nix#bast-bin
```

Install several packages in one command:

```bash
nix profile install \
  github:tinypkg/nix#bast-bin \
  github:tinypkg/nix#mise-bin \
  github:tinypkg/nix#fizzy-cli-bin
```

List or remove packages in your profile:

```bash
nix profile list
nix profile remove bast-bin
```

Upgrade packages installed from this flake:

```bash
nix profile upgrade '.*'
```

Run a CLI without installing it permanently:

```bash
nix run github:tinypkg/nix#autocli-bin -- --help
```

Build or download a package into `./result`:

```bash
nix build github:tinypkg/nix#fizzy-cli-bin
```

## Coming from AUR

Nix does not register these packages in pacman. It places immutable package
contents in the Nix store and adds selected executables to a user profile.

| AUR / pacman concept | Nix equivalent in this repository |
| --- | --- |
| AUR package name | Flake package attribute after `#`, such as `bast-bin` |
| `paru -S foo` | `nix profile install github:tinypkg/nix#foo` |
| `pacman -Rns foo` | `nix profile remove foo` |
| `paru -Syu` | `nix profile upgrade '.*'` |
| `PKGBUILD` | `packages/<name>/package.nix` plus `source.json` |
| `pkgver`, `source`, checksums | `version` and per-system sources in `source.json` |
| `depends` | `runtimeDependencies` in `package.nix` |
| `package()` | A shared `kind` installer, or a package-local `build.nix` override |
| `.SRCINFO` | Flake outputs generated from the package directories |

The terms used in the commands above mean:

- A **flake** is a versioned Nix repository with declared inputs and outputs.
  This repository's outputs are its packages.
- The text after `#` is the exact package attribute to select.
- A **profile** is the set of packages exposed to one user. It is independent
  of pacman and can be listed, upgraded, or rolled back by Nix.
- `/nix/store` contains immutable, content-addressed package results. Do not
  edit files there manually.
- A **fixed hash** proves that an upstream download has exactly the expected
  contents. Nix refuses a changed download until its hash is updated.
- `flake.lock` pins nixpkgs and repository tooling. Each application's version,
  download URL, and artifact hash remain local to its own `source.json`.

The `-bin` suffix keeps the familiar AUR naming convention. These packages use
upstream prebuilt artifacts; Nix still performs an installation derivation to
unpack and patch them, but it does not compile the applications from source.

### NixOS

Add the repository as a flake input and reference the package for your system:

```nix
{
  inputs.tinypkg.url = "github:tinypkg/nix";

  outputs = { nixpkgs, tinypkg, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            tinypkg.packages.x86_64-linux.bast-bin
          ];
        }
      ];
    };
  };
}
```

### Home Manager

Reference the same flake input from a Home Manager module:

```nix
{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.tinypkg.packages.${pkgs.system}.bast-bin
  ];
}
```

## Packages

Availability depends on the architectures published by each upstream project.
Run `nix flake show github:tinypkg/nix` on the target system for the exact list.

| Package | Description | Upstream |
| --- | --- | --- |
| `autocli-bin` | Fast CLI for fetching information from websites | [AutoCLI](https://github.com/nashsu/AutoCLI) |
| `bast-bin` | SSH host browser and key manager | [Bast](https://bast.sh) |
| `blink1-tiny-server-bin` | HTTP API server for blink(1) devices | [blink1-tool](https://github.com/todbot/blink1-tool) |
| `blink1-tool-bin` | CLI for blink(1) devices | [blink1-tool](https://github.com/todbot/blink1-tool) |
| `blink1control2-bin` | Graphical blink(1) controller | [Blink1Control2](https://github.com/todbot/Blink1Control2) |
| `boo-bin` | libghostty-based terminal multiplexer | [Boo](https://github.com/coder/boo) |
| `cc-switch-bin` | Desktop configuration manager for coding assistants | [CC Switch](https://github.com/farion1231/cc-switch) |
| `cc-switch-cli` | CLI configuration manager for coding assistants | [cc-switch-cli](https://github.com/SaladDay/cc-switch-cli) |
| `cc-switchy-bin` | Restore CC Switch cloud snapshots | [cc-switchy](https://github.com/ca-x/cc-switchy) |
| `clauge-bin` | Desktop development-tool workspace | [Clauge](https://clauge.in) |
| `codiff-bin` | Local Git diff viewer | [Codiff](https://github.com/nkzw-tech/codiff) |
| `con-bin` | Terminal emulator with an AI harness | [Con](https://con.nowledge.co) |
| `confirmo-bin` | Desktop AI coding companion | [Confirmo](https://confirmo.love) |
| `cumora-bin` | Workspace for AI teammates | [Cumora](https://cumora.ai) |
| `dbx-bin` | Cross-platform database client | [DBX](https://github.com/t8y2/dbx) |
| `docking-bin` | GTK desktop dock | [Docking](https://github.com/edumucelli/docking) |
| `druk-bin` | Terminal code editor | [Druk](https://github.com/letstri/druk) |
| `emdash-app` | Run coding agents in parallel | [Emdash](https://github.com/generalaction/emdash) |
| `fizzy-cli-bin` | Manage Fizzy boards and tasks | [fizzy-cli](https://github.com/basecamp/fizzy-cli) |
| `hclient-cli-bin` | Lazycat Microserver CLI | [Lazycat](https://lazycat.cloud/download) |
| `herdr-bin` | Supervise coding agents in one terminal | [Herdr](https://github.com/ogulcancelik/herdr) |
| `karing-bin` | Clash and sing-box proxy utility | [Karing](https://github.com/KaringX/karing) |
| `little-snitch-bin` | Outgoing connection monitor | [Little Snitch](https://obdev.at/products/littlesnitch) |
| `llmux-bin` | Multi-provider Claude proxy | [llmux](https://github.com/2lab-ai/llmux) |
| `lucarned-bin` | Remote notifications for local coding agents | [Lucarne](https://github.com/tuchg/Lucarne) |
| `mimo-code-bin` | AI coding assistant | [MiMo Code](https://mimo.xiaomi.com/mimocode) |
| `mise-bin` | Developer tool and task runner | [mise](https://github.com/jdx/mise) |
| `nmem-cli` | Nowledge Mem CLI and TUI | [Nowledge Mem](https://mem.nowledge.co/docs/cli) |
| `nowledge-mem-bin` | Shared memory desktop application | [Nowledge Mem](https://mem.nowledge.co) |
| `openless-bin` | AI-polished push-to-talk dictation | [OpenLess](https://github.com/Open-Less/openless) |
| `read-aware-bin` | Local-first AI-native reader | [ReadAware](https://github.com/ahpxex/read-aware) |
| `revpdf-bin` | Offline PDF editor | [RevPDF](https://github.com/Pawandeep-prog/revpdf-release) |
| `tldraw-offline-bin` | Local whiteboard for people and agents | [tldraw offline](https://github.com/tldraw/tldraw-offline) |
| `tty7-bin` | GPU-rendered terminal workbench | [tty7](https://github.com/l0ng-ai/tty7) |
| `tunnix-bin` | Encrypted proxy tunnel over HTTP/SSE | [Tunnix](https://github.com/aeroxy/tunnix) |
| `uniclipboard-bin` | Encrypted cross-platform clipboard sync | [UniClipboard](https://www.uniclipboard.app) |
| `velotype-bin` | Native Markdown editor | [Velotype](https://github.com/manyougz/velotype) |
| `virtualhere-client-bin` | USB-over-network client | [VirtualHere](https://www.virtualhere.com/usb_server_software) |
| `whatcable-cli-bin` | Report USB cable capabilities | [whatcable-linux](https://github.com/Zetaphor/whatcable-linux) |
| `z-code-bin` | AI agents integrated with development toolchains | [ZCode](https://zcode.z.ai) |

## Install through AUR instead

Arch and Omarchy users who prefer native pacman-managed packages can continue
using AUR. Install the required build tools first:

```bash
sudo pacman -S --needed base-devel git
```

With an AUR helper:

```bash
paru -S bast-bin
# or
yay -S bast-bin
```

Without an AUR helper:

```bash
git clone https://aur.archlinux.org/bast-bin.git
cd bast-bin
makepkg -si
```

Replace `bast-bin` with any package name from the table. Do not run `makepkg` as
root. AUR definitions and their release automation live in
[tinypkg/aur](https://github.com/tinypkg/aur).

## Automatic updates

Every 12 hours, GitHub Actions checks each application's upstream GitHub
Release, PyPI project, update manifest, or product endpoint directly. It
downloads changed artifacts to calculate Nix fixed hashes, updates the pinned
nixpkgs revision, evaluates packages independently, and attempts representative
prebuilt-package builds. Valid changes are committed directly to `main` by
`github-actions[bot]`. The update workflow performs the same structural,
evaluation, and representative-build checks before creating that commit.

Repository structure and formatting checks remain blocking. Package evaluation
and representative builds run independently: a broken package is reported as a
GitHub warning and in the job summary, then the workflow continues with the
remaining packages instead of failing the complete check. CI never runs an
installed application binary.

Run the updater manually from **Actions → Update packages → Run workflow**.

## Add a package

No central package manifest is required. A new directory is discovered
automatically by the flake:

```text
packages/example-bin/
├── package.nix
└── source.json
```

Start with the installation metadata in `package.nix`:

```nix
{
  description = "Short description of the application";
  homepage = "https://github.com/owner/example";
  license = "mit";
  kind = "archive";
  executables = [ "example" ];
  runtimeDependencies = [ "openssl" ];
}
```

Then pin versions and artifacts independently in `source.json`:

```json
{
  "version": "1.2.3",
  "sources": {
    "x86_64-linux": {
      "url": "https://github.com/owner/example/releases/download/v1.2.3/example-x86_64.tar.gz",
      "hash": "sha256-REPLACE_WITH_THE_REAL_SRI_HASH"
    },
    "aarch64-linux": {
      "url": "https://github.com/owner/example/releases/download/v1.2.3/example-aarch64.tar.gz",
      "hash": "sha256-REPLACE_WITH_THE_REAL_SRI_HASH"
    }
  },
  "update": {
    "method": "github",
    "repo": "owner/example"
  }
}
```

Only systems present under `sources` export the package. Calculate each initial
fixed hash with the following command; it downloads the artifact but does not
run it:

```bash
nix store prefetch-file --json \
  https://github.com/owner/example/releases/download/v1.2.3/example-x86_64.tar.gz
```

The common installer supports `archive`, `raw`, `deb`, `archpkg`, `appimage`,
and `wheel`. Use `bundle = true` when an archive must retain adjacent files,
declare library providers in `runtimeDependencies`, and add a package-local
`build.nix` only when the shared installer cannot describe the artifact.

To finish the package:

1. Add its name to `tests/expected-packages.txt` in sorted order.
2. Add one row to the package table in both language versions of the README.
3. Run `./scripts/check.sh` for metadata and documentation checks.
4. Run `./scripts/check-packages.sh evaluate` to evaluate every package while
   allowing unrelated broken packages to be skipped.
5. Commit the new directory. The GitHub updater will handle later version and
   fixed-hash changes directly from upstream on `main`.

Supported update methods are `github`, `pypi`, `json`, `yaml`, `html`, and
`manual`. Copy a nearby `source.json` using the same upstream type rather than
putting update logic in a central list.

## Contributing

```bash
nix develop
./scripts/check.sh
./scripts/check-packages.sh evaluate
./scripts/check-packages.sh build autocli-bin blink1-tool-bin revpdf-bin
```

Each application is isolated under `packages/<name>/`: `package.nix` describes
how its prebuilt artifact is installed, while `source.json` owns its version,
per-architecture URLs, fixed hashes, and independent upstream update strategy.
A package does not need an AUR entry to be added here. Packages with unusual
installation requirements can add a local `build.nix` without changing other
applications.
