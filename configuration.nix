{ config, lib, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      grub = {
        device = "/dev/sda";
        enable = true;
        version = 2;
      };
    };

    cleanTmpDir = true;
  };

  fileSystems = [
    {
      device = "/dev/sda2";
      fsType = "ext4";
      mountPoint = "/";
    }
  ];

  swapDevices = [
    {
      device = "/dev/sda1";
    }
  ];

  networking = {
    hostName = "valeera";
    hostId = "7019ee34";
    networkmanager = {
      enable = true;
      insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
    };
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [ zsh ];
    variables = {
      QT_QPA_PLATFORMTHEME="qt5ct";
    };
  };

  time.timeZone = "Asia/Manila";

  security.sudo = {
    enable = true;
    configFile = ''
      Defaults env_reset
      root ALL = (ALL:ALL) ALL
      %wheel ALL = (ALL) SETENV: NOPASSWD: ALL
    '';
  };

  services = {
    avahi = {
      enable = true;
      hostName = config.networking.hostName;
      ipv4 = true;
      nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    xserver = {
      autorun = true;
      defaultDepth = 24;
      enable = true;
      desktopManager.gnome3.enable = true;
      displayManager = {
        lightdm.enable = true;
      };
      videoDrivers = [ "nvidia" ];
    };
    openssh = {
      enable = true;
      ports = [ 9876 ];
      passwordAuthentication = false;
      permitRootLogin = "no";
    };
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplipWithPlugin pkgs.canon-cups-ufr2 ];
    };
  };

  virtualisation = {
    virtualbox = {
      host = {
        enable = true;
      };
    };
    docker = {
      enable = true;
      extraOptions = "-H tcp://0.0.0.0:2375 -s overlay2";
    };
  };

  users = {
    extraUsers.zhaqenl = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" "networkmanager" "lp" "docker" ];
    };
    defaultUserShell = "/run/current-system/sw/bin/zsh";
  };

  programs = {
    command-not-found.enable = true;
    ssh.startAgent = true;
  };  

  nixpkgs.config.allowUnfree = true;
  services.gnome3.chrome-gnome-shell.enable = true;
  system.autoUpgrade.enable = true;
}
