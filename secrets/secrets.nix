let
  nc-s1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOyDFssCQrib8qTyES84xXPN4amCj1bT475lySpEj+F8 root@nc-s1";
  ur = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrroIk7zXYrvqtlSN1XXgfX0csTHeDiTEP0jYRklFbe ur@pi-mac.local";
  epack-le = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4tg/CImmKHgTF82McKgKsaSjfaHE7cWqlT+F4eGIwh ur@epack-le";
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
  "ur-nc-s1-hash.age".publicKeys = todos;
  "root-nc-s1-hash.age".publicKeys = todos;
  "ur-epack-le-hash.age".publicKeys = [
    epack-le
    nc-s1
    ur
  ];
  "mdfz-env.age".publicKeys = todos;
}
