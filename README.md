# nix-infra

`nc-s1`: Servidor dedicado (bare metal) en Netcup. 

## Estructura

```
nix-infra/
├── flake.nix                         
├── hosts/nc-s1/
│   ├── configuration.nix             
│   └── hardware-configuration.nix    
├── modules/nixos/
│   ├── common.nix                    
│   ├── security/{ssh,firewall}.nix
│   └── services/{nginx,postgresql,garage,tailscale,cloudflared}.nix
└── secrets/secrets.nix               
```
