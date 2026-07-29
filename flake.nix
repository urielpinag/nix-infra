{
  description = "nix-infra — infraestructura declarativa Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      ...
    }@inputs:
    let
      linuxSystem = "x86_64-linux";
      specialArgs = { inherit inputs; };
    in
    {
      nixosConfigurations.nc-s1 = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        inherit specialArgs;
        modules = [
          ./hosts/nc-s1/configuration.nix
          ./hosts/nc-s1/hardware-configuration.nix
          agenix.nixosModules.default
          ./modules/nixos/common.nix
          ./modules/nixos/security/ssh.nix
          ./modules/nixos/security/firewall.nix
          ./modules/nixos/services/nginx.nix
          ./modules/nixos/services/postgresql.nix
          ./modules/nixos/services/garage.nix
          ./modules/nixos/services/tailscale.nix
          ./modules/nixos/services/cloudflared.nix
        ];
      };

      formatter.${linuxSystem} = nixpkgs.legacyPackages.${linuxSystem}.nixfmt-rfc-style;
    };
}
