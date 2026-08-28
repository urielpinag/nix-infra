{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cli.helix;

  yaziBinding = ''
    [keys.normal]
    C-e = [
      ':sh rm -f /tmp/unique-file',
      ':insert-output yazi %{buffer_name} --chooser-file=/tmp/unique-file',
      ':insert-output echo "\x1b[?1049h\x1b[?2004h" > /dev/tty',
      ':open %sh{cat /tmp/unique-file}',
      ':redraw',
    ]
  '';

  configToml = ''
    [editor]
    bufferline = "always"
    default-yank-register = "+"
    soft-wrap.enable = true

    [editor.indent-guides]
    render = true
    skip-levels = 1

    ${lib.optionalString cfg.yaziIntegration yaziBinding}
  '';

  languagesToml = ''
    [language]
    indent = { tab-width = 2, unit = "  " }
  '';
in
{
  options.cli.helix = {
    enable = lib.mkEnableOption "config de Helix compartida (config.toml + languages.toml)";

    yaziIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Incluir el binding C-e que abre yazi como selector de archivos.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        helix
      ]
      ++ lib.optionals cfg.yaziIntegration [
        yazi
        wl-clipboard
      ];

    systemd.tmpfiles.rules = [
      "d /home/ur/.config/helix 0755 ur users - -"
      "C+ /home/ur/.config/helix/config.toml - - - ${pkgs.writeText "helix-config.toml" configToml}"
      "C+ /home/ur/.config/helix/languages.toml - - - ${pkgs.writeText "helix-languages.toml" languagesToml}"
    ];
  };
}
