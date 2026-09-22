{ config, lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  cfg = config.shared.cli.helix;

  yaziBinding = ''
    [keys.normal]
    C-e = [
      ':sh rm -f /tmp/unique-file',
      ':insert-output yazi %{buffer_name} --chooser-file=/tmp/unique-file',
      ${
        if isDarwin then
          "':insert-output printf \"\\x1b[?1049h\\x1b[?2004h\\x1b[?1000h\\x1b[?1002h\\x1b[?1006h\" > /dev/tty',"
        else
          "':insert-output echo \"\\x1b[?1049h\\x1b[?2004h\" > /dev/tty',"
      }
      ':open %sh{cat /tmp/unique-file}',
      ':redraw',
    ]
  '';

  clipboard = ''
    [editor.clipboard-provider]
    pasteboard = {}
  '';

  # LSPs para los lenguajes principales. Helix ya los referencia por default
  # en su languages.toml embebido; aquí solo instalamos los binarios.
  # Excluibles (p. ej. en servidores) vía cfg.includeLsps.
  lspPackages = [
    pkgs.clang-tools # clangd (C/C++)
    pkgs.rust-analyzer
    pkgs.phpactor
    pkgs.typescript-language-server
    pkgs.typescript
    pkgs.pyright
    pkgs.ruff # linter/formatter de Python (complementario a pyright)
    pkgs.nil # Nix
  ];

  configToml = ''
    [editor]
    bufferline = "always"
    default-yank-register = "+"
    soft-wrap.enable = true

    [editor.indent-guides]
    render = true
    skip-levels = 1

    ${lib.optionalString isDarwin clipboard}

    ${lib.optionalString cfg.yaziIntegration yaziBinding}
  '';

  languagesToml = ''
    [[language]]
    name = "c"
    scope = "source.c"
    language-servers = ["clangd"]
    indent = { tab-width = 2, unit = "  " }

    [[language]]
    name = "rust"
    scope = "source.rust"
    language-servers = ["rust-analyzer"]
    indent = { tab-width = 2, unit = "  " }

    [[language]]
    name = "php"
    scope = "source.php"
    language-servers = ["phpactor"]
    indent = { tab-width = 2, unit = "  " }

    [[language]]
    name = "javascript"
    scope = "source.js"
    language-servers = ["typescript-language-server"]
    indent = { tab-width = 2, unit = "  " }

    [[language]]
    name = "typescript"
    scope = "source.ts"
    language-servers = ["typescript-language-server"]
    indent = { tab-width = 2, unit = "  " }

    [[language]]
    name = "python"
    scope = "source.python"
    language-servers = ["pyright", "ruff"]
    indent = { tab-width = 2, unit = "  " }

    [language-server.phpactor]
    command = "phpactor"
    args = ["language-server"]
  '';
in
{
  options.shared.cli.helix = {
    enable = lib.mkEnableOption "Config de Helix compartida (config.toml + languages.toml)";

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

    configToml = lib.mkOption {
      type = lib.types.str;
      description = "Contenido de config.toml.";
    };

    languagesToml = lib.mkOption {
      type = lib.types.str;
      description = "Contenido de languages.toml.";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "Paquetes de helix.";
    };
  };

  config = lib.mkIf cfg.enable {
    shared.cli.helix = {
      configToml = configToml;
      languagesToml = languagesToml;
      packages = [ pkgs.helix ]
        ++ lib.optionals cfg.includeLsps lspPackages
        ++ lib.optionals cfg.yaziIntegration ([
          pkgs.yazi
        ] ++ lib.optional (!isDarwin) pkgs.wl-clipboard);
    };
  };
}
