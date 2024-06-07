# Build with:
#   NIXOS_CONFIG="$PWD/configuration.nix" nixos-rebuild build-vm --max-jobs auto --builders '' 
#   # ...you might need `nix-shell -p nixos-rebuild` as it's only installed on NixOS
# Run with:
#   ./result/bin/run-*-vm &
# Interesting customizations for using the existing terminal emulator:
#   QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-nixos-vm -nographic; reset

{ pkgs, lib, config, ... }:

{
  imports = [
    ./custom.nix
    #./.kitty.nix  # Comment this, if you're not me
  ];

  users.mutableUsers = false;
  users.users.root.hashedPassword = "";
  services.getty.autologinUser = "root";

  environment.extraSetup = ''
    rm --force $out/bin/nix-channel
  '';
  nix.channel.enable = false;
  environment.etc.nixpkgs.source = pkgs.path;
  nix = {  
    nixPath = [ "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ]; #"nixpkgs-overlays=/etc/nixos/nixpkgs/overlays.nix"
    settings = {
      flake-registry = "";
      trusted-users = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
      nix-path = config.nix.nixPath;  # see: # https://github.com/NixOS/nix/issues/9574 https://github.com/NixOS/nix/issues/10246 
    };
  };
  nixpkgs.overlays = [ ]; # import ./nixpkgs/overlays.nix
  nixpkgs.config = { }; # import ./nixpkgs/config.nix
  # environment.variables.NIXPKGS_CONFIG = lib.mkForce "/etc/nixos/nixpkgs/config.nix";
  system.stateVersion = config.system.nixos.release;

  programs.git.enable = true;
  programs.neovim = { enable = true; defaultEditor = true; viAlias = true; vimAlias = true; };
  environment.systemPackages = with pkgs; [ ripgrep ];

  virtualisation.vmVariant = {
    virtualisation = {
      qemu.options = [ "-vga virtio" ];
      diskImage = null; # "./nixos.qcow2";
      sharedDirectories.share = { source = toString ./.; target = "/etc/nixos"; };
      mountHostNixStore = true;
      writableStoreUseTmpfs = false;
      forwardPorts = [
        { from = "host"; host.port = 9880; guest.port = 80; }
        { from = "host"; host.port = 9980; guest.port = 9980; }
        { from = "host"; host.port = 9443; guest.port = 443; }
        { from = "host"; host.port = 9943; guest.port = 9943; }
        { from = "host"; host.port = 9922; guest.port = 22; }
      ];
    };
    networking.firewall.allowedTCPPorts = [ 80 443 9980 9943 ];
    environment.shellAliases = {
      sht = "sudo shutdown -h now";
      tt = "stty columns 200; stty rows 70;";
    };
  };

  boot.loader.grub.device = "nodev";
  fileSystems."/" = {};
}
