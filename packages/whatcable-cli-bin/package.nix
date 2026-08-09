{
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
}
