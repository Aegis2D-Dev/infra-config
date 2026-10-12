{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/github-runners.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.useDHCP = false;
  networking.interfaces.ens18.ipv4.addresses = [{
    address = "10.40.20.250";
    prefixLength = 24;
  }];
  networking.defaultGateway = "10.40.20.254";
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  nix.settings = {
    max-jobs = 6;
    cores = 6;
  };

  system.stateVersion = "26.05";
}
