# tinypkg Nix packages

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
nixpkgs revision, evaluates the complete flake, and builds representative
prebuilt packages. Changes are submitted as a pull request instead of being
pushed directly to `main`.

Run the updater manually from **Actions → Update packages → Run workflow**.

## Contributing

```bash
nix develop
./scripts/check.sh
nix flake check --all-systems
```

Package behavior is defined in `packages/metadata.nix`; versions, URLs, and
hashes are stored in `packages/sources.json`; independent upstream update
strategies live in `packages/update.json`. A package does not need an AUR entry
to be added here.
