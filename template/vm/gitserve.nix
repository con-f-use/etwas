{ config, pkgs, lib, ... }:
let
  repos = "/var/lib/git";
in
{
  users.users.git = {
    isSystemUser = true;
    shell = "${config.programs.git.package}/bin/git-shell";
    # ignoreShellProgramCheck = true;
    password = "!";
    createHome = true;
    home = repos;
    openssh = {
      authorizedPrincipals = [ "git" "qa" "user" "main" "admin" "root" ];
      authorizedKeys.keys = [ ];
      authorizedKeys.keyFiles = [ ];
    };
  };

  systemd.tmpfiles.rules = [ "Z ${repos} git users 0640" ];

  services.gitDaemon = {
    enable = true;
    basePath = repos;
    exportAll = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    authorizedKeysFiles = [];
    allowSFTP = lib.mkDefault false;
    settings = {
      UseDns = lib.mkDefault false;
      PasswordAuthentication = lib.mkDefault false;
      GatewayPorts = lib.mkDefault "no";
      PermitRootLogin = lib.mkDefault "prohibit-password";
      X11Forwarding = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
    };
  };
  # services.sshguard.enable = true;
}
