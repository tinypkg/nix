{
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
    "libxcb"
  ];
}
