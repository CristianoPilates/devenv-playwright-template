{ pkgs, inputs, ... }:

let
  pkgs-playwright = import inputs.nixpkgs-playwright {
    system = pkgs.stdenv.system;
  };
  browsers = builtins.fromJSON (builtins.readFile "${pkgs-playwright.playwright-driver}/browsers.json");
  chromium = builtins.head (builtins.filter (browser: browser.name == "chromium") browsers.browsers);
  chromium-rev = chromium.revision;
  nodeExtractMajorMinor = value: ''
    ${pkgs.nodejs}/bin/node -e 'const v = process.argv[1]; const clean = v.replace(/^[^0-9]*/, ""); const m = clean.match(/^([0-9]+\.[0-9]+)/); if (!m) process.exit(1); process.stdout.write(m[1]);' "$1"
  '';
in
{
  packages = [
    pkgs.nodejs
  ];

  env = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs-playwright.playwright.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
    PLAYWRIGHT_NODEJS_PATH = "${pkgs.nodejs}/bin/node";
    PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH = "${pkgs-playwright.playwright.browsers}/chromium-${chromium-rev}/chrome-linux/chrome";
  };

  languages.javascript = {
    enable = true;
    npm.install.enable = true;
  };

  enterShell = ''
    set -euo pipefail

    nix_playwright_version="${pkgs-playwright.playwright-driver.version}"
    npm_playwright_version="$(${pkgs.nodejs}/bin/node -e 'const pkg = require("./package.json"); process.stdout.write(pkg.devDependencies?.["@playwright/test"] ?? "");')"
    nix_playwright_major_minor="$(${nodeExtractMajorMinor} "$nix_playwright_version")"
    npm_playwright_major_minor="$(${nodeExtractMajorMinor} "$npm_playwright_version")"

    if [ "$nix_playwright_major_minor" != "$npm_playwright_major_minor" ]; then
      echo "Playwright version mismatch: nix=${pkgs-playwright.playwright-driver.version} npm=$npm_playwright_version" >&2
      echo "Align @playwright/test with nixpkgs-playwright on major.minor." >&2
      return 1
    fi
  '';
}
