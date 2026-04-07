{ pkgs, inputs, ... }:

let
  pkgs-playwright = import inputs.nixpkgs-playwright {
    system = pkgs.stdenv.system;
  };
  browsers = builtins.fromJSON (builtins.readFile "${pkgs-playwright.playwright-driver}/browsers.json");
  chromium = builtins.head (builtins.filter (browser: browser.name == "chromium") browsers.browsers);
  chromium-rev = chromium.revision;
  extractMajorMinor = value:
    builtins.head (builtins.match "^[^0-9]*([0-9]+\.[0-9]+).*$" value);
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
  playwrightVersion = packageJson.devDependencies."@playwright/test" or "";
  nixPlaywrightMajorMinor = extractMajorMinor pkgs-playwright.playwright-driver.version;
  packagePlaywrightMajorMinor = extractMajorMinor playwrightVersion;
in
{
  packages = [
    pkgs.nodejs
    pkgs.bun
  ];

  env = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs-playwright.playwright.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
    PLAYWRIGHT_NODEJS_PATH = "${pkgs.nodejs}/bin/node";
    PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH = "${pkgs-playwright.playwright.browsers}/chromium-${chromium-rev}/chrome-linux/chrome";
  };

  languages.javascript = {
    enable = true;
    bun.enable = true;
  };

  enterShell = ''
    set -euo pipefail

    if [ -z "${playwrightVersion}" ]; then
      echo "Missing devDependencies.\"@playwright/test\" in package.json" >&2
      return 1
    fi

    if [ "${nixPlaywrightMajorMinor}" != "${packagePlaywrightMajorMinor}" ]; then
      echo "Playwright version mismatch: nix=${pkgs-playwright.playwright-driver.version} package=${playwrightVersion}" >&2
      echo "Align @playwright/test with nixpkgs-playwright on major.minor." >&2
      return 1
    fi
  '';
}
