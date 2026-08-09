{
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
}
