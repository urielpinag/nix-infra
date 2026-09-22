{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.helix;
  sharedCfg = config.shared.cli.helix;
in
{
  imports = [ ../../shared/cli/helix.nix ];

  options.cli.helix = {
    enable = lib.mkEnableOption "config de Helix compartida (config.toml + languages.toml)";

    yaziIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Incluir el binding C-e que abre yazi como selector de archivos.";
    };

    includeLsps = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Instalar los LSPs de los lenguajes principales (desactivar en servidores).";
    };
  };

  config = lib.mkIf cfg.enable {
    shared.cli.helix.enable = true;
    shared.cli.helix.yaziIntegration = cfg.yaziIntegration;
    shared.cli.helix.includeLsps = cfg.includeLsps;
    environment.systemPackages = sharedCfg.packages;

    systemd.tmpfiles.rules = [
      "d /home/ur/.config/helix 0755 ur users - -"
      "C+ /home/ur/.config/helix/config.toml - - - ${pkgs.writeText "helix-config.toml" sharedCfg.configToml}"
      "C+ /home/ur/.config/helix/languages.toml - - - ${pkgs.writeText "helix-languages.toml" sharedCfg.languagesToml}"
    ];
  };
}
