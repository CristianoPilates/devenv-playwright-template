{ pkgs, inputs, ... }:

let
  pkgs-playwright = import inputs.nixpkgs-playwright {
    system = pkgs.stdenv.system;
  };
  browsers = builtins.fromJSON (builtins.readFile "${pkgs-playwright.playwright-driver}/browsers.json");
  chromium = builtins.head (builtins.filter (browser: browser.name == "chromium") browsers.browsers);
  chromium-rev = chromium.revision;
in
{
  packages = [
    pkgs.bun
    pkgs-playwright.playwright-driver.browsers
  ];

  env = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs-playwright.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
    PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH = "${pkgs-playwright.playwright-driver.browsers}/chromium-${chromium-rev}/chrome-linux/chrome";
  };

  languages.javascript = {
    enable = true;
    bun.enable = true;
  };
}
