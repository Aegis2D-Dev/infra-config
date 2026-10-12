{ config, lib, pkgs, ... }:

let
  runners = map (i: "cust-aegis2d-01-${toString i}") [ 1 2 3 ];
in
{
  sops.secrets.github-runner-token = {
    sopsFile = ../../secrets/cust-aegis2d-01.yaml;
    restartUnits = map (name: "github-runner-${name}.service") runners;
  };

  services.github-runners = lib.genAttrs runners (name: {
    enable = true;
    inherit name;
    url = "https://github.com/Aegis2D-Dev";
    tokenFile = config.sops.secrets.github-runner-token.path;
    replace = true;
    ephemeral = true;
    extraLabels = [ "nixos" ];
    extraPackages = with pkgs; [ gcc cmake gnumake ninja pkg-config ];
  });
}
