{
  description = "Terminal UI and CLI for browsing SSH hosts and managing keys";
  homepage = "https://bast.sh";
  license = "mit";
  kind = "archive";
  executables = [ "bast" ];
  runtimeDependencies = [ "openssh" ];
}
