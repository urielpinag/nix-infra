let
  nc-s1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOyDFssCQrib8qTyES84xXPN4amCj1bT475lySpEj+F8 root@nc-s1";
  ur = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrroIk7zXYrvqtlSN1XXgfX0csTHeDiTEP0jYRklFbe ur@pi-mac.local";
  todos = [
    nc-s1
    ur
  ];
in
{
  "cloudflared-creds.age".publicKeys = todos;
  "garage-rpc-secret.age".publicKeys = todos;
  "restic-env.age".publicKeys = todos;
  "sge-env.age".publicKeys = todos;
}
