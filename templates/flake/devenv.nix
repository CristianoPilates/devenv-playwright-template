{ pkgs, inputs, ... }:

let
  pkgs-playwright = import inputs.nixpkgs-playwright {
    system = pkgs.stdenv.system;
  };
in
{
  packages = [
    pkgs.bun
    pkgs-playwright.playwright
    pkgs-playwright.playwright-test
    pkgs-playwright.playwright-driver.browsers
  ];

  env = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs-playwright.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
  };

  enterShell = ''
    rm -rf node_modules/playwright node_modules/playwright-core
    mkdir -p node_modules/@playwright
    ln -sfn ${pkgs-playwright.playwright-test}/lib/node_modules/@playwright/test \
      node_modules/@playwright/test
    ln -sfn ${pkgs-playwright.playwright} node_modules/playwright-core
    ln -sfn ${pkgs-playwright.playwright} node_modules/playwright
  '';

  languages.javascript = {
    enable = true;
    bun.enable = true;
  };
}
