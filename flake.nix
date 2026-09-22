{
  description = "nix-infra — infraestructura declarativa Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    sge.url = "git+ssh://git@github.com/urielpinag/SMS-UR?ref=main";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      nix-darwin,
      home-manager,
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
          ./modules/nixos/cli/languages.nix
          ./modules/nixos/services/podman.nix
        ];
      };

      formatter = {
        ${linuxSystem} = nixpkgs.legacyPackages.${linuxSystem}.nixfmt;
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
      };

      darwinConfigurations.pi-mac = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        inherit specialArgs;
        modules = [
          ./modules/darwin/default.nix
          agenix.darwinModules.default
          home-manager.darwinModules.home-manager
        ];
      };
    };
}
