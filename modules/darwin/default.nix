{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  system.stateVersion = 6;

  ids.gids.nixbld = 350;

  users.users.ur = {
    name = "ur";
    uid = 501;
    gid = 20;
    home = "/Users/ur";
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.ur = {
    imports = [
      ./packages.nix
      ./fonts.nix
      ./dotfiles.nix
    ];

    _module.args.inputs = inputs;

    home.stateVersion = "24.11";
  };
}
