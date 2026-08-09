{
  description = "High-performance native Markdown editor";
  homepage = "https://github.com/manyougz/velotype";
  license = "apache2";
  kind = "archive";
  executables = [ "velotype" ];
  copyDirectories = [ "share" ];
  runtimeDependencies = [
    "libxkbcommon"
    "libxcb"
  ];
}
