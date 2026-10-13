{ config, lib, pkgs, ... }:

let
  host = config.networking.hostName;
  # Three runners per host, named after it: <host>-1, <host>-2, <host>-3.
  runners = map (i: "${host}-${toString i}") [ 1 2 3 ];

  # Only Node 24 is packaged (Node 20 is EOL), but the runner still runs hashFiles()
  # with externals/node20: point that path at Node 24 too.
  runnerPackage = pkgs.github-runner.overrideAttrs (old: {
    postInstall = old.postInstall + ''
      ln -s ${pkgs.nodejs_24} $out/lib/externals/node20
    '';
  });
in
{
  sops.secrets.github-runner-token = {
    sopsFile = ../secrets + "/${host}.yaml";
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

  # CPM sources shared by the container jobs of every runner on this host (mounted at
  # /cpm-cache, CPM locks its downloads); entries unused for 30 days are removed.
  systemd.tmpfiles.rules = [ "d /var/cache/ci-cpm 0755 root root 30d" ];

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
    package = runnerPackage;
    extraPackages = [ pkgs.docker ];
    extraEnvironment.ACTIONS_RUNNER_FORCE_ACTIONS_NODE_VERSION = "node24";
    serviceOverrides = {
      SupplementaryGroups = [ "docker" ];
      # Container jobs read /proc/1/cgroup and talk to the Docker socket; docker group
      # membership is root-equivalent anyway, so these isolations add nothing.
      ProtectProc = "default";
      PrivateUsers = false;
    };
  });
}
