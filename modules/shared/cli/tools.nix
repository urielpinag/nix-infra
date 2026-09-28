{ config, lib, pkgs, inputs, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  cfg = config.shared.cli.tools;
  llm-agentsPkgs = pkgs.extend inputs.llm-agents.overlays.shared-nixpkgs;
in
{
  options.shared.cli.tools = {
    enable = lib.mkEnableOption "Herramientas CLI del workstation (lazygit, opencode2, lazydocker, mdcat, slumber, pi)";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "Paquetes CLI del workstation.";
    };
  };

  config = lib.mkIf cfg.enable {
    shared.cli.tools.packages = with pkgs; [
      lazygit
      lazydocker
      mdcat
      slumber
      llm-agentsPkgs.llm-agents.pi
      llm-agentsPkgs.llm-agents.opencode2
    ] ++ lib.optional (!isDarwin) wl-clipboard;
  };
}
