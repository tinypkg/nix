{
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
}
