{ config, lib, pkgs, ... }:
let
  cfg = config.shared.languages;
in
{
  options.shared.languages = {
    enable = lib.mkEnableOption "Compiladores e intérpretes (c, rust, php, javascript/typescript, python)";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "Compiladores e intérpretes.";
    };
  };

  config = lib.mkIf cfg.enable {
    shared.languages.packages = with pkgs; [
      clang # C (clang/LLVM)
      rustc # Rust
      cargo # Rust build tool
      php # PHP
      nodejs # JavaScript runtime
      typescript # TypeScript compiler (tsc)
      python3 # Python interpreter
    ];
  };
}
