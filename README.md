# nix-infra

Infraestructura declarativa Nix para:

- `nc-s1`: servidor dedicado (bare metal) en Netcup.
- `epack-le`: workstation NixOS con GNOME.
- `pi-mac`: Mac con nix-darwin + home-manager.

## Estructura

```
nix-infra/
├── flake.nix
├── hosts/
│   ├── nc-s1/
│   ├── epack-le/
├── modules/
│   ├── nixos/
│   │   ├── common.nix
│   │   ├── user/
│   │   ├── cli/
│   │   ├── security/
│   │   └── services/
│   ├── darwin/
│   └── shared/
│       └── cli/
└── secrets/
```
