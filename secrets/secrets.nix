let
  nc-s1-hsk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOyDFssCQrib8qTyES84xXPN4amCj1bT475lySpEj+F8 root@nc-s1";
  epack-le-hsk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbRogOpB6VT9p72wlJCyLyAQ0/UKubPPTE9OTplAyWX root@epack-le";
  pi-mac-ur = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrroIk7zXYrvqtlSN1XXgfX0csTHeDiTEP0jYRklFbe ur@pi-mac.local";
  epack-le-ur = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4tg/CImmKHgTF82McKgKsaSjfaHE7cWqlT+F4eGIwh ur@epack-le";
  todos = [
    nc-s1-hsk
    pi-mac-ur
    epack-le-ur
  ];
in
{
  "cloudflared-creds.age".publicKeys = todos;
  "garage-rpc-secret.age".publicKeys = todos;
  "sge-env.age".publicKeys = todos;
  "ur-nc-s1-hash.age".publicKeys = todos;
  "root-nc-s1-hash.age".publicKeys = todos;
  "ur-epack-le-hash.age".publicKeys = [ epack-le-hsk ] ++ todos;
}
