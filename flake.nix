{
  description = "devenv + Playwright flake template";

  outputs = { self }: {
    templates.default = {
      path = ./templates/flake;
      description = "Minimal devenv + Playwright template";
    };
  };
}
