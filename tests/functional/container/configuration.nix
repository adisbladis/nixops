{ pkgs, config, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/docker-image.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    (builtins.readFile ../snakeoil/id_ed25519.pub)
  ];

  services.openssh.enable = true;

  # We're not using the host resolver
  services.resolved.enable = true;
  networking.useHostResolvConf = false;
  networking.nameservers = [
    "1.1.1.1"
    "9.9.9.9"
  ];

  services.journald.console = "/dev/console";

  # We are using a local Nix daemon
  environment.variables.NIX_REMOTE = lib.mkForce "";

  # For some reason /etc/ssh gets the wrong permissions
  boot.postBootCommands = ''
    chown -R root:root /etc/ssh
  '';

  # security.audit.enable = lib.mkForce false;
  # is not sufficient as it's explicitly _disabled_ rather than just a no-op
  systemd.services.audit.serviceConfig = {
    ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";
    ExecStop = lib.mkForce "${pkgs.coreutils}/bin/true";
  };

  systemd.suppressedSystemUnits = [
    "sys-kernel-config.mount"
    "sys-kernel-debug.mount"
    "systemd-journald-audit.socket"
  ];

  environment.systemPackages = with pkgs; [
    bashInteractive
    cacert
    nix
  ];
}
