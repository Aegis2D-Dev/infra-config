{
  description = "Aegis2D infra - configurations NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, comin, ... }:
    let
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          comin.nixosModules.comin
          ./modules/common.nix
          ./hosts/${hostname}/configuration.nix
          { networking.hostName = hostname; }
        ];
      };
    in
    {
      nixosConfigurations = {
        cust-aegis2d-01 = mkHost "cust-aegis2d-01";
      };
    };
}
