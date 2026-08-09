{
  description = "Command-line tool for controlling blink(1) USB RGB LEDs";
  homepage = "https://github.com/todbot/blink1-tool";
  license = "custom";
  kind = "archive";
  executables = [ "blink1-tool" ];
  runtimeDependencies = [
    "libusb1"
    "libudev-zero"
  ];
}
