{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.languages;
  sharedCfg = config.shared.languages;
in
{
  imports = [ ../../shared/languages.nix ];

  options.cli.languages = {
    enable = lib.mkEnableOption "Compiladores e intérpretes (c, rust, php, javascript/typescript, python)";
  };

  config = lib.mkIf cfg.enable {
    shared.languages.enable = true;
    environment.systemPackages = sharedCfg.packages;
  };
}
