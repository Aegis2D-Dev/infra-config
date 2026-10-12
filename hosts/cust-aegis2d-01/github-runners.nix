{ config, lib, pkgs, ... }:

let
  runners = map (i: "cust-aegis2d-01-${toString i}") [ 1 2 3 ];
in
{
  sops.secrets.github-runner-token = {
    sopsFile = ../../secrets/cust-aegis2d-01.yaml;
    restartUnits = map (name: "github-runner-${name}.service") runners;
  };

  # Jobs run in Ubuntu containers (`container:` in the workflows).
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Clang 18's ASan crashes with the 32 bits of mmap randomization some kernels use.
  boot.kernel.sysctl."vm.mmap_rnd_bits" = 28;

  services.github-runners = lib.genAttrs runners (name: {
    enable = true;
    inherit name;
    url = "https://github.com/Aegis2D-Dev";
    tokenFile = config.sops.secrets.github-runner-token.path;
    replace = true;
    ephemeral = true;
    extraLabels = [ "nixos" ];
    extraPackages = [ pkgs.docker ];
    # Only Node 24 is packaged (Node 20 is EOL): use it for hashFiles() and node20 actions too.
    extraEnvironment = {
      ACTIONS_RUNNER_FORCED_INTERNAL_NODE_VERSION = "node24";
      ACTIONS_RUNNER_FORCE_ACTIONS_NODE_VERSION = "node24";
    };
    serviceOverrides = {
      SupplementaryGroups = [ "docker" ];
      # Container jobs read /proc/1/cgroup and talk to the Docker socket; docker group
      # membership is root-equivalent anyway, so these isolations add nothing.
      ProtectProc = "default";
      PrivateUsers = false;
    };
  });
}
