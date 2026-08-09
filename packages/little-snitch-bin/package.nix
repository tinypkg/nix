{
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
}
