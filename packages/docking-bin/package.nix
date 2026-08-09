{
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
}
