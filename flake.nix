{
  description = "devenv + Playwright templates";

  outputs =
    { self }:
    {
      templates.default = {
        path = ./templates/flake;
        description = "Minimal devenv + Playwright (flake.nix entry)";
      };
      templates.devenv-nix = {
        path = ./templates/devenv-nix;
        description = "Minimal devenv + Playwright (devenv.nix only, no flake)";
      };
    };
}
