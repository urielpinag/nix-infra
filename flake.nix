{
  description = "nix-infra — infraestructura declarativa Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    sge.url = "github:urielpinag/SMS-UR";
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
          ./modules/nixos/user/ur.nix
          ./modules/nixos/cli/helix.nix
          ./modules/nixos/security/ssh.nix
          ./modules/nixos/security/firewall.nix
          ./modules/nixos/services/nginx.nix
          ./modules/nixos/services/postgresql.nix
          ./modules/nixos/services/garage.nix
          ./modules/nixos/services/tailscale.nix
          ./modules/nixos/services/cloudflared.nix
          ./modules/nixos/services/sge.nix
        ];
      };

      nixosConfigurations.epack-le = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        inherit specialArgs;
        modules = [
          ./hosts/epack-le/configuration.nix
          ./hosts/epack-le/hardware-configuration.nix
          agenix.nixosModules.default
          ./modules/nixos/common.nix
          ./modules/nixos/user/ur.nix
          ./modules/nixos/cli/helix.nix
          ./modules/nixos/cli/tmux.nix
          ./modules/nixos/cli/alacritty.nix
          ./modules/nixos/cli/starship.nix
          ./modules/nixos/cli/zsh.nix
          ./modules/nixos/cli/tools.nix
          ./modules/nixos/services/podman.nix
        ];
      };

      formatter.${linuxSystem} = nixpkgs.legacyPackages.${linuxSystem}.nixfmt-rfc-style;
    };
}
