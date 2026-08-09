# tinypkg Nix 软件包

[English](README.md) | [**简体中文**](README.zh-CN.md)

[![Check](https://github.com/tinypkg/nix/actions/workflows/check.yml/badge.svg)](https://github.com/tinypkg/nix/actions/workflows/check.yml)
[![Update packages](https://github.com/tinypkg/nix/actions/workflows/update.yml/badge.svg)](https://github.com/tinypkg/nix/actions/workflows/update.yml)

`tinypkg/nix` 为 [tinypkg/aur](https://github.com/tinypkg/aur) 中维护的 Linux
预编译软件提供可复现的 Nix 软件包。它会下载上游发布产物、校验固定哈希、解包，
并在需要时修补运行库路径，不会从源码编译这些应用程序。

## 安装 Nix

### Omarchy 和 Arch Linux

安装发行版软件包，初始化 Nix store，并启动守护进程：

```bash
sudo pacman -S nix
sudo nix-store --init
sudo systemctl enable --now nix-daemon.service
```

在 `/etc/nix/nix.conf` 中加入：

```ini
build-users-group = nixbld
experimental-features = nix-command flakes
```

修改配置后重启守护进程：

```bash
sudo systemctl restart nix-daemon.service
nix --version
```

`nixbld` 是受限的构建用户组，不要把自己的登录用户加入该组。

### 其他 Linux 发行版

使用官方多用户安装器：

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

安装后重新打开 shell。如果安装器尚未启用 `nix-command` 和 `flakes`，请将上面的
`experimental-features` 配置加入 `/etc/nix/nix.conf`。

## 使用本仓库

查看当前系统可用的软件包：

```bash
nix flake show github:tinypkg/nix
```

把一个软件安装到当前用户的 profile：

```bash
nix profile install github:tinypkg/nix#bast-bin
```

一次批量安装多个软件：

```bash
nix profile install \
  github:tinypkg/nix#bast-bin \
  github:tinypkg/nix#mise-bin \
  github:tinypkg/nix#fizzy-cli-bin
```

查看或卸载 profile 中的软件：

```bash
nix profile list
nix profile remove bast-bin
```

升级通过 flake 安装的软件：

```bash
nix profile upgrade '.*'
```

不永久安装，临时运行一个 CLI：

```bash
nix run github:tinypkg/nix#autocli-bin -- --help
```

只构建或下载软件包，并在当前目录创建 `./result` 链接：

```bash
nix build github:tinypkg/nix#fizzy-cli-bin
```

## 从 AUR 迁移时需要理解的概念

Nix 不会把这些软件登记到 pacman。软件内容存放在不可变的 Nix store 中，选择安装
的软件再通过当前用户的 profile 暴露出来。

| AUR / pacman 概念 | 本仓库中的 Nix 对应项 |
| --- | --- |
| AUR 包名 | `#` 后面的 flake 软件包属性，例如 `bast-bin` |
| `paru -S foo` | `nix profile install github:tinypkg/nix#foo` |
| `pacman -Rns foo` | `nix profile remove foo` |
| `paru -Syu` | `nix profile upgrade '.*'` |
| `PKGBUILD` | `packages/<名称>/package.nix` 加 `source.json` |
| `pkgver`、`source`、校验和 | `source.json` 中的版本和各系统下载源 |
| `depends` | `package.nix` 中的 `runtimeDependencies` |
| `package()` | 通用 `kind` 安装器，特殊情况使用包内 `build.nix` |
| `.SRCINFO` | 根据软件目录自动生成的 flake outputs |

常见 Nix 术语：

- **flake** 是声明了输入和输出、可锁定版本的 Nix 仓库。本仓库的主要输出就是软件包。
- `#` 后的文字是要选择的软件包属性名。
- **profile** 是暴露给某个用户的一组软件，与 pacman 相互独立，可以由 Nix 查看、
  升级、卸载和回滚。
- `/nix/store` 保存不可变、按内容寻址的结果，不要手工修改其中的文件。
- **固定哈希**用来证明上游下载内容与预期完全一致。上游偷偷替换文件后，Nix 会拒绝
  继续使用，直到维护者确认并更新哈希。
- `flake.lock` 锁定 nixpkgs 和仓库工具版本；每个应用自己的版本、下载地址和产物哈希
  仍分别保存在它自己的 `source.json` 中。

包名保留了 AUR 用户熟悉的 `-bin` 后缀。这些包使用上游预编译产物；Nix 仍会执行
解包和修补所需的安装 derivation，但不会编译应用源码。

### NixOS

把仓库加入 flake inputs，然后按系统引用多个软件包：

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
            tinypkg.packages.x86_64-linux.mise-bin
            tinypkg.packages.x86_64-linux.fizzy-cli-bin
          ];
        }
      ];
    };
  };
}
```

### Home Manager

在 Home Manager module 中引用同一个 flake input：

```nix
{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.tinypkg.packages.${pkgs.system}.bast-bin
    inputs.tinypkg.packages.${pkgs.system}.mise-bin
    inputs.tinypkg.packages.${pkgs.system}.fizzy-cli-bin
  ];
}
```

## 软件列表

实际可用架构取决于上游发布的产物。请在目标系统运行
`nix flake show github:tinypkg/nix` 查看准确列表。

| 软件包 | 说明 | 上游 |
| --- | --- | --- |
| `autocli-bin` | 快速获取网站信息的 CLI | [AutoCLI](https://github.com/nashsu/AutoCLI) |
| `bast-bin` | SSH 主机浏览器和密钥管理器 | [Bast](https://bast.sh) |
| `blink1-tiny-server-bin` | blink(1) 设备的 HTTP API 服务 | [blink1-tool](https://github.com/todbot/blink1-tool) |
| `blink1-tool-bin` | blink(1) 设备命令行工具 | [blink1-tool](https://github.com/todbot/blink1-tool) |
| `blink1control2-bin` | blink(1) 图形控制器 | [Blink1Control2](https://github.com/todbot/Blink1Control2) |
| `boo-bin` | 基于 libghostty 的终端多路复用器 | [Boo](https://github.com/coder/boo) |
| `cc-switch-bin` | 编码助手桌面配置管理器 | [CC Switch](https://github.com/farion1231/cc-switch) |
| `cc-switch-cli` | 编码助手命令行配置管理器 | [cc-switch-cli](https://github.com/SaladDay/cc-switch-cli) |
| `cc-switchy-bin` | 恢复 CC Switch 云快照 | [cc-switchy](https://github.com/ca-x/cc-switchy) |
| `clauge-bin` | 桌面开发工具工作区 | [Clauge](https://clauge.in) |
| `codiff-bin` | 本地 Git diff 查看器 | [Codiff](https://github.com/nkzw-tech/codiff) |
| `con-bin` | 集成 AI harness 的终端模拟器 | [Con](https://con.nowledge.co) |
| `confirmo-bin` | 桌面 AI 编码助手 | [Confirmo](https://confirmo.love) |
| `cumora-bin` | AI 队友工作区 | [Cumora](https://cumora.ai) |
| `dbx-bin` | 跨平台数据库客户端 | [DBX](https://github.com/t8y2/dbx) |
| `docking-bin` | GTK 桌面 Dock | [Docking](https://github.com/edumucelli/docking) |
| `druk-bin` | 终端代码编辑器 | [Druk](https://github.com/letstri/druk) |
| `emdash-app` | 并行运行多个编码代理 | [Emdash](https://github.com/generalaction/emdash) |
| `fizzy-cli-bin` | 管理 Fizzy 看板和任务 | [fizzy-cli](https://github.com/basecamp/fizzy-cli) |
| `hclient-cli-bin` | 懒猫微服 CLI | [Lazycat](https://lazycat.cloud/download) |
| `herdr-bin` | 在一个终端监督多个编码代理 | [Herdr](https://github.com/ogulcancelik/herdr) |
| `karing-bin` | Clash 与 sing-box 代理工具 | [Karing](https://github.com/KaringX/karing) |
| `little-snitch-bin` | 出站连接监控器 | [Little Snitch](https://obdev.at/products/littlesnitch) |
| `llmux-bin` | 多提供商 Claude 代理 | [llmux](https://github.com/2lab-ai/llmux) |
| `lucarned-bin` | 为本地编码代理提供远程通知 | [Lucarne](https://github.com/tuchg/Lucarne) |
| `mimo-code-bin` | AI 编码助手 | [MiMo Code](https://mimo.xiaomi.com/mimocode) |
| `mise-bin` | 开发工具和任务运行器 | [mise](https://github.com/jdx/mise) |
| `nmem-cli` | Nowledge Mem CLI 与 TUI | [Nowledge Mem](https://mem.nowledge.co/docs/cli) |
| `nowledge-mem-bin` | 共享记忆桌面应用 | [Nowledge Mem](https://mem.nowledge.co) |
| `openless-bin` | AI 优化的按键说话听写工具 | [OpenLess](https://github.com/Open-Less/openless) |
| `read-aware-bin` | 本地优先的 AI 原生阅读器 | [ReadAware](https://github.com/ahpxex/read-aware) |
| `revpdf-bin` | 离线 PDF 编辑器 | [RevPDF](https://github.com/Pawandeep-prog/revpdf-release) |
| `tldraw-offline-bin` | 面向用户和代理的本地白板 | [tldraw offline](https://github.com/tldraw/tldraw-offline) |
| `tty7-bin` | GPU 渲染终端工作台 | [tty7](https://github.com/l0ng-ai/tty7) |
| `tunnix-bin` | 通过 HTTP/SSE 的加密代理隧道 | [Tunnix](https://github.com/aeroxy/tunnix) |
| `uniclipboard-bin` | 加密跨平台剪贴板同步 | [UniClipboard](https://www.uniclipboard.app) |
| `velotype-bin` | 原生 Markdown 编辑器 | [Velotype](https://github.com/manyougz/velotype) |
| `virtualhere-client-bin` | USB over network 客户端 | [VirtualHere](https://www.virtualhere.com/usb_server_software) |
| `whatcable-cli-bin` | 查看 USB 线缆能力 | [whatcable-linux](https://github.com/Zetaphor/whatcable-linux) |
| `z-code-bin` | 集成开发工具链的 AI 代理 | [ZCode](https://zcode.z.ai) |

## 仍然通过 AUR 安装

希望继续由 pacman 管理软件的 Arch 和 Omarchy 用户仍可使用 AUR。先安装必要工具：

```bash
sudo pacman -S --needed base-devel git
```

使用 AUR helper：

```bash
paru -S bast-bin
# 或
yay -S bast-bin
```

不使用 AUR helper：

```bash
git clone https://aur.archlinux.org/bast-bin.git
cd bast-bin
makepkg -si
```

把 `bast-bin` 替换为列表中的包名。不要以 root 运行 `makepkg`。AUR 定义及其发布
自动化位于 [tinypkg/aur](https://github.com/tinypkg/aur)。

## 自动更新和检查

GitHub Actions 每 12 小时直接检查每个软件的 GitHub Release、PyPI 项目、更新清单
或产品接口。发现新版本后，由 GitHub 下载产物并计算 Nix 固定哈希，同时更新锁定的
nixpkgs。通过检查的改动由 `github-actions[bot]` 直接提交到 `main`，不再创建
pull request；提交前，更新工作流自身会完成结构、求值和代表性构建检查。

仓库结构和格式错误仍会阻止工作流。各软件包的求值和代表性构建相互独立：某个包
失败时会产生 GitHub warning 并写入 Job Summary，随后继续检查其他包，不会让单个
上游问题拖垮整次检查。CI 只构建包，不会运行任何已经安装的应用程序。

可在 **Actions → Update packages → Run workflow** 手动运行更新器，也可以指定单个
软件包和版本。

## 新增软件

不需要维护中央软件清单。flake 会自动发现新的独立目录：

```text
packages/example-bin/
├── package.nix
└── source.json
```

先在 `package.nix` 中描述安装方式：

```nix
{
  description = "软件的简短说明";
  homepage = "https://github.com/owner/example";
  license = "mit";
  kind = "archive";
  executables = [ "example" ];
  runtimeDependencies = [ "openssl" ];
}
```

再由该软件自己的 `source.json` 保存版本、各架构产物和更新策略：

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

只有 `sources` 中出现的系统才会导出该软件。首次加入时，需要为每个产物计算固定
哈希。下面的命令只下载文件并输出 SRI 哈希，不会运行软件：

```bash
nix store prefetch-file --json \
  https://github.com/owner/example/releases/download/v1.2.3/example-x86_64.tar.gz
```

通用安装器支持 `archive`、`raw`、`deb`、`archpkg`、`appimage` 和 `wheel`。
归档中的程序必须保留相邻文件时设置 `bundle = true`；动态库提供者写入
`runtimeDependencies`；只有通用安装器无法描述的特殊软件才增加包内 `build.nix`。

完成新软件还需要：

1. 按排序把包名加入 `tests/expected-packages.txt`。
2. 在中英文 README 的软件列表中各增加一行。
3. 运行 `./scripts/check.sh` 检查元数据和文档。
4. 运行 `./scripts/check-packages.sh evaluate` 求值全部包；不相关的坏包会被跳过。
5. 提交新目录。此后的新版本和固定哈希由 GitHub 更新器直接在 `main` 上维护。

更新方式支持 `github`、`pypi`、`json`、`yaml`、`html` 和 `manual`。优先复制一个
使用相同上游类型的软件的 `source.json`，不要把软件专属更新逻辑放回中央大文件。

## 参与维护

```bash
nix develop
./scripts/check.sh
./scripts/check-packages.sh evaluate
./scripts/check-packages.sh build autocli-bin blink1-tool-bin revpdf-bin
```

每个应用都隔离在 `packages/<名称>/` 下：`package.nix` 描述如何安装预编译产物，
`source.json` 独立管理版本、各架构 URL、固定哈希和上游更新策略。新增 Nix 包不要求
先有对应 AUR 包；特殊安装需求可以使用本目录的 `build.nix`，不会影响其他应用。
