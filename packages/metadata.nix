{
  autocli-bin = {
    description = "Blazing fast, memory-safe CLI tool for fetching information from websites";
    homepage = "https://github.com/nashsu/AutoCLI";
    license = "mit";
    kind = "archive";
    executables = [ "autocli" ];
  };

  bast-bin = {
    description = "Terminal UI and CLI for browsing SSH hosts and managing keys";
    homepage = "https://bast.sh";
    license = "mit";
    kind = "archive";
    executables = [ "bast" ];
    runtimeDependencies = [ "openssh" ];
  };

  blink1-tiny-server-bin = {
    description = "HTTP JSON API server for controlling blink(1) USB RGB LEDs";
    homepage = "https://github.com/todbot/blink1-tool";
    license = "custom";
    kind = "archive";
    executables = [ "blink1-tiny-server" ];
    runtimeDependencies = [ "libusb1" ];
  };

  blink1-tool-bin = {
    description = "Command-line tool for controlling blink(1) USB RGB LEDs";
    homepage = "https://github.com/todbot/blink1-tool";
    license = "custom";
    kind = "archive";
    executables = [ "blink1-tool" ];
    runtimeDependencies = [ "libusb1" ];
  };

  blink1control2-bin = {
    description = "Graphical controller for blink(1) USB RGB LED devices";
    homepage = "https://github.com/todbot/Blink1Control2";
    license = "custom";
    kind = "deb";
  };

  boo-bin = {
    description = "GNU screen-style terminal multiplexer built on libghostty";
    homepage = "https://github.com/coder/boo";
    license = "mit";
    kind = "archive";
    executables = [ "boo" ];
  };

  cc-switch-bin = {
    description = "Desktop assistant for Claude Code, Codex, and Gemini CLI";
    homepage = "https://github.com/farion1231/cc-switch";
    license = "mit";
    kind = "deb";
  };

  cc-switch-cli = {
    description = "CLI assistant for Claude Code, Codex, and Gemini CLI";
    homepage = "https://github.com/SaladDay/cc-switch-cli";
    license = "mit";
    kind = "archive";
    executables = [ "cc-switch" ];
  };

  cc-switchy-bin = {
    description = "CLI/TUI for restoring CC Switch cloud snapshots";
    homepage = "https://github.com/ca-x/cc-switchy";
    license = "mit";
    kind = "archive";
    executables = [ "cc-switchy" ];
  };

  clauge-bin = {
    description = "One window for every development tool";
    homepage = "https://clauge.in";
    license = "unknown";
    kind = "deb";
  };

  codiff-bin = {
    description = "Minimal local Git diff viewer";
    homepage = "https://github.com/nkzw-tech/codiff";
    license = "mit";
    kind = "deb";
  };

  con-bin = {
    description = "Native terminal emulator with a built-in AI harness";
    homepage = "https://con.nowledge.co";
    license = "mit";
    kind = "archive";
    executables = [
      "con"
      "con-cli"
    ];
    runtimeDependencies = [
      "libxkbcommon"
      "xorg.libxcb"
    ];
  };

  confirmo-bin = {
    description = "AI coding companion that lives on the desktop";
    homepage = "https://confirmo.love";
    license = "mit";
    kind = "deb";
  };

  cumora-bin = {
    description = "Workspace where AI teammates live";
    homepage = "https://cumora.ai";
    license = "unknown";
    kind = "deb";
  };

  dbx-bin = {
    description = "Lightweight cross-platform database client";
    homepage = "https://github.com/t8y2/dbx";
    license = "mit";
    kind = "deb";
  };

  docking-bin = {
    description = "Feature-rich GTK desktop dock";
    homepage = "https://github.com/edumucelli/docking";
    license = "gpl3";
    kind = "archpkg";
    runtimeDependencies = [
      "gobject-introspection"
      "gtk3"
      "libwnck"
      "networkmanager"
      "python3"
    ];
  };

  druk-bin = {
    description = "Terminal code editor with tabs, search, and Git integration";
    homepage = "https://github.com/letstri/druk";
    license = "mit";
    kind = "archive";
    executables = [ "druk" ];
  };

  emdash-app = {
    description = "Run multiple coding agents in parallel";
    homepage = "https://github.com/generalaction/emdash";
    license = "mit";
    kind = "deb";
    mainProgram = "emdash";
  };

  fizzy-cli-bin = {
    description = "CLI for managing Fizzy boards, cards, comments, and tasks";
    homepage = "https://github.com/basecamp/fizzy-cli";
    license = "mit";
    kind = "archive";
    executables = [ "fizzy" ];
  };

  hclient-cli-bin = {
    description = "Lazycat Microserver command-line client";
    homepage = "https://lazycat.cloud/download";
    license = "mit";
    kind = "raw";
    executables = [ "hclient-cli" ];
  };

  herdr-bin = {
    description = "Supervise multiple coding agents in one terminal";
    homepage = "https://github.com/ogulcancelik/herdr";
    license = "agpl3Plus";
    kind = "raw";
    executables = [ "herdr" ];
  };

  karing-bin = {
    description = "Proxy utility with Clash and sing-box routing support";
    homepage = "https://github.com/KaringX/karing";
    license = "gpl3";
    kind = "deb";
  };

  little-snitch-bin = {
    description = "Monitor and control outgoing application connections";
    homepage = "https://obdev.at/products/littlesnitch";
    license = "gpl2";
    kind = "archpkg";
    runtimeDependencies = [
      "audit"
      "libcap_ng"
      "pam"
      "sqlite"
    ];
  };

  llmux-bin = {
    description = "Multi-provider Claude proxy with quota-based account rotation";
    homepage = "https://github.com/2lab-ai/llmux";
    license = "mit";
    kind = "raw";
    executables = [ "llmux" ];
  };

  lucarned-bin = {
    description = "Remote notifications and approvals for local AI coding agents";
    homepage = "https://github.com/tuchg/Lucarne";
    license = "mit";
    kind = "archive";
    executables = [ "lucarned" ];
  };

  mimo-code-bin = {
    description = "AI coding assistant with unlimited context";
    homepage = "https://mimo.xiaomi.com/mimocode";
    license = "mit";
    kind = "archive";
    executables = [ "mimo" ];
  };

  mise-bin = {
    description = "Developer tools, environment variables, and task runner";
    homepage = "https://github.com/jdx/mise";
    license = "mit";
    kind = "archive";
    executables = [ "mise" ];
  };

  nmem-cli = {
    description = "CLI and TUI for Nowledge Mem";
    homepage = "https://mem.nowledge.co/docs/cli";
    license = "mit";
    kind = "wheel";
    mainProgram = "nmem";
    pythonDependencies = [
      "python3Packages.httpx"
      "python3Packages.pyperclip"
      "python3Packages.qrcode"
      "python3Packages.rich"
      "python3Packages.textual"
    ];
  };

  nowledge-mem-bin = {
    description = "Shared memory for agents, AI assistants, and coding tools";
    homepage = "https://mem.nowledge.co";
    license = "proprietary";
    kind = "deb";
  };

  openless-bin = {
    description = "Push-to-talk AI-polished dictation for the desktop";
    homepage = "https://github.com/Open-Less/openless";
    license = "mit";
    kind = "deb";
    runtimeDependencies = [ "xdotool" ];
  };

  read-aware-bin = {
    description = "Local-first AI-native reader";
    homepage = "https://github.com/ahpxex/read-aware";
    license = "mit";
    kind = "deb";
  };

  revpdf-bin = {
    description = "Free offline PDF editor";
    homepage = "https://github.com/Pawandeep-prog/revpdf-release";
    license = "custom";
    kind = "appimage";
    mainProgram = "revpdf-bin";
  };

  tldraw-offline-bin = {
    description = "Local whiteboard for people and agents";
    homepage = "https://github.com/tldraw/tldraw-offline";
    license = "proprietary";
    kind = {
      x86_64 = "deb";
      aarch64 = "appimage";
    };
    mainProgram = "tldraw-offline";
  };

  tty7-bin = {
    description = "GPU-rendered terminal workbench for shells, SSH, and coding agents";
    homepage = "https://github.com/l0ng-ai/tty7";
    license = "apache2";
    kind = "archive";
    executables = [ "tty7" ];
    bundle = true;
    runtimeDependencies = [
      "fontconfig"
      "freetype"
      "krb5"
      "libglvnd"
      "libxkbcommon"
      "vulkan-loader"
      "wayland"
      "xorg.libX11"
      "xorg.libxcb"
    ];
  };

  tunnix-bin = {
    description = "Encrypted SOCKS5 and HTTP proxy tunnel over HTTP/SSE";
    homepage = "https://github.com/aeroxy/tunnix";
    license = "mit";
    kind = "archive";
    executables = [ "tunnix" ];
  };

  uniclipboard-bin = {
    description = "Local-first encrypted clipboard synchronization";
    homepage = "https://www.uniclipboard.app";
    license = "agpl3";
    kind = "deb";
  };

  velotype-bin = {
    description = "High-performance native Markdown editor";
    homepage = "https://github.com/manyougz/velotype";
    license = "apache2";
    kind = "archive";
    executables = [ "velotype" ];
    copyDirectories = [ "share" ];
    runtimeDependencies = [
      "libxkbcommon"
      "xorg.libxcb"
    ];
  };

  virtualhere-client-bin = {
    description = "VirtualHere USB-over-network client";
    homepage = "https://www.virtualhere.com/usb_server_software";
    license = "bsd";
    kind = "raw";
    executables = [ "vhclient" ];
  };

  whatcable-cli-bin = {
    description = "CLI that reports the capabilities of connected USB cables";
    homepage = "https://github.com/Zetaphor/whatcable-linux";
    license = "mit";
    kind = "archive";
    executables = [
      {
        name = "whatcable";
        source = "whatcable-linux";
      }
    ];
    runtimeDependencies = [
      "qt6.qtbase"
      "systemd"
    ];
  };

  z-code-bin = {
    description = "AI agents integrated with existing development toolchains";
    homepage = "https://zcode.z.ai";
    license = "custom";
    kind = "deb";
  };
}
