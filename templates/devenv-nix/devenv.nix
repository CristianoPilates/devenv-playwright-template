{ pkgs, inputs, ... }:

let
  pkgs-playwright = import inputs.nixpkgs-playwright {
    system = pkgs.stdenv.system;
  };
in

{
  packages = with pkgs; [
    bun
    libsecret
    pkgs-playwright.playwright-driver
  ];

  env = {
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs-playwright.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "1";
  };

  languages = {
    javascript = {
      enable = true;
      bun.enable = true;
    };
  };
}
