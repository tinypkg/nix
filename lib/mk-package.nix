{ pkgs, system }:

let
  inherit (pkgs) lib;

  systemToArch = {
    x86_64-linux = "x86_64";
    aarch64-linux = "aarch64";
    riscv64-linux = "riscv64";
    powerpc64le-linux = "ppc64le";
  };

  arch = systemToArch.${system};

  resolvePackage = path: lib.attrByPath (lib.splitString "." path) null pkgs;

  licenseMap = {
    mit = lib.licenses.mit;
    agpl3 = lib.licenses.agpl3Only;
    agpl3Plus = lib.licenses.agpl3Plus;
    apache2 = lib.licenses.asl20;
    bsd = lib.licenses.bsd3;
    gpl2 = lib.licenses.gpl2Only;
    gpl3 = lib.licenses.gpl3Only;
    proprietary = lib.licenses.unfree;
    unknown = lib.licenses.unfree;
    custom = lib.licenses.unfreeRedistributable;
  };

  licenseFor = name: licenseMap.${name};

  commonDesktopDependencies = lib.filter (dependency: dependency != null) (
    map resolvePackage [
      "alsa-lib"
      "at-spi2-core"
      "cairo"
      "cups"
      "dbus"
      "expat"
      "fontconfig"
      "freetype"
      "glib"
      "gtk3"
      "libayatana-appindicator"
      "libdrm"
      "libgbm"
      "libnotify"
      "libsecret"
      "libxkbcommon"
      "mesa"
      "nspr"
      "nss"
      "pango"
      "systemd"
      "webkitgtk_4_1"
      "libx11"
      "libxcomposite"
      "libxdamage"
      "libxext"
      "libxfixes"
      "libxi"
      "libxrandr"
      "libxrender"
      "libxscrnsaver"
      "libxtst"
      "libxcb"
    ]
  );

  fetchArtifact =
    name: artifact:
    pkgs.fetchurl (
      {
        inherit (artifact) url;
        name = artifact.fileName or "${name}-${builtins.baseNameOf artifact.url}";
      }
      // lib.optionalAttrs (artifact ? hash) { inherit (artifact) hash; }
      // lib.optionalAttrs (artifact ? sha256) { inherit (artifact) sha256; }
    );
in
spec:
let
  inherit (spec) name sourceInfo;
  inherit (sourceInfo) version;
  artifact = sourceInfo.sources.${system};
  kind = if builtins.isAttrs spec.kind then spec.kind.${arch} else spec.kind;
  src = fetchArtifact name artifact;
  executableNames = spec.executables or [ (lib.removeSuffix "-bin" name) ];
  firstExecutable = builtins.head executableNames;
  mainProgram =
    spec.mainProgram
      or (if builtins.isString firstExecutable then firstExecutable else firstExecutable.name);
  runtimeDependencies = lib.filter (dependency: dependency != null) (
    [ pkgs.stdenv.cc.cc.lib ]
    ++ lib.optionals (builtins.elem kind [
      "deb"
      "appimage"
    ]) commonDesktopDependencies
    ++ map resolvePackage (spec.runtimeDependencies or [ ])
  );
  meta = {
    inherit (spec) description homepage;
    license = licenseFor spec.license;
    maintainers = [ ];
    platforms = builtins.attrNames sourceInfo.sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    inherit mainProgram;
  };

  archiveInstall = lib.concatMapStringsSep "\n" (
    executable:
    let
      sourceName = executable.source or executable.name;
    in
    if spec.bundle or false then
      ''
        candidate=$(find "$out/lib/${name}" -type f -name ${lib.escapeShellArg sourceName} -print -quit)
        if [ -z "$candidate" ]; then
          echo "unable to find ${sourceName} in ${name}" >&2
          exit 1
        fi
        ln -s "$candidate" "$out/bin/${executable.name}"
      ''
    else
      ''
        candidate=$(find . -type f -name ${lib.escapeShellArg sourceName} -print -quit)
        if [ -z "$candidate" ]; then
          echo "unable to find ${sourceName} in ${name}" >&2
          exit 1
        fi
        install -Dm755 "$candidate" "$out/bin/${executable.name}"
      ''
  ) (map (entry: if builtins.isString entry then { name = entry; } else entry) executableNames);

  normalPackage = pkgs.stdenvNoCC.mkDerivation {
    pname = name;
    inherit version src;
    sourceRoot = lib.optionalString (kind == "archive") ".";

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.dpkg
      pkgs.libarchive
      pkgs.makeWrapper
      pkgs.unzip
      pkgs.xz
      pkgs.zstd
    ];

    dontUnpack = builtins.elem kind [
      "archpkg"
      "deb"
      "raw"
    ];

    unpackPhase = lib.optionalString (kind == "archpkg") ''
      runHook preUnpack
      mkdir root
      bsdtar -xf "$src" -C root
      runHook postUnpack
    '';

    installPhase =
      if kind == "deb" then
        ''
          runHook preInstall
          mkdir root "$out"
          dpkg-deb -x "$src" root
          if [ -d root/usr ]; then cp -a root/usr/. "$out/"; fi
          if [ -d root/opt ]; then cp -a root/opt "$out/opt"; fi
          if [ -d root/etc ]; then cp -a root/etc "$out/etc"; fi
          runHook postInstall
        ''
      else if kind == "archpkg" then
        ''
          runHook preInstall
          mkdir -p "$out"
          if [ -d root/usr ]; then cp -a root/usr/. "$out/"; fi
          if [ -d root/opt ]; then cp -a root/opt "$out/opt"; fi
          if [ -d root/etc ]; then cp -a root/etc "$out/etc"; fi
          runHook postInstall
        ''
      else if kind == "raw" then
        ''
          runHook preInstall
          mkdir -p "$out/bin"
          install -m755 "$src" "$out/bin/${mainProgram}"
          runHook postInstall
        ''
      else
        ''
          runHook preInstall
          mkdir -p "$out/bin"
          ${lib.optionalString (spec.bundle or false) ''
            mkdir -p "$out/lib/${name}"
            cp -a . "$out/lib/${name}/"
          ''}
          ${archiveInstall}
          ${lib.concatMapStringsSep "\n" (directory: ''
            if [ -d ${lib.escapeShellArg directory} ]; then
              mkdir -p "$out/${builtins.dirOf directory}"
              cp -a ${lib.escapeShellArg directory} "$out/${directory}"
            fi
          '') (spec.copyDirectories or [ ])}
          runHook postInstall
        '';

    inherit runtimeDependencies;
    autoPatchelfIgnoreMissingDeps = spec.ignoreMissingDependencies or [ ];

    preFixup = ''
      if [ -d "$out" ]; then
        while IFS= read -r -d $'\0' link; do
          target=$(readlink "$link")
          case "$target" in
            /usr/*) ln -sfn "$out/''${target#/usr/}" "$link" ;;
            /opt/*) ln -sfn "$out$target" "$link" ;;
          esac
        done < <(find "$out" -type l -print0)

        if [ -d "$out/share/applications" ]; then
          while IFS= read -r -d $'\0' desktop; do
            substituteInPlace "$desktop" \
              --replace-fail "/usr/bin/" "$out/bin/" 2>/dev/null || true
            substituteInPlace "$desktop" \
              --replace-fail "/opt/" "$out/opt/" 2>/dev/null || true
          done < <(find "$out/share/applications" -type f -print0)
        fi
      fi
    '';

    inherit meta;
  };
in
if kind == "appimage" then
  pkgs.appimageTools.wrapType2 {
    pname = name;
    inherit version src meta;
    extraPkgs = _: runtimeDependencies;
    extraInstallCommands = lib.optionalString (mainProgram != name) ''
      ln -s "$out/bin/${name}" "$out/bin/${mainProgram}"
    '';
  }
else if kind == "wheel" then
  pkgs.python3Packages.buildPythonApplication {
    pname = name;
    inherit version src meta;
    format = "wheel";
    propagatedBuildInputs = map resolvePackage (spec.pythonDependencies or [ ]);
    doCheck = false;
  }
else
  normalPackage
