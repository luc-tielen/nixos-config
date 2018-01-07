# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos";      # Define your hostname.
    wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    enableIPv6 = true;
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  # HW settings:
  hardware = {
    cpu.intel.updateMicrocode = true;

    # Make use of integrated Intel + nvidia GPU
    bumblebee = {
      connectDisplay = true;  # connects discrete card to monitor??
      enable = true;
      driver = "nvidia";
    };
    opengl = {
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiIntel ];
    };

    pulseaudio.enable = true;  # Enable sound
    bluetooth.enable = false;  # Turn off bluetooth
  };

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      fira-code
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    bash.enableCompletion = true;
    zsh = {
      enable = true;
      promptInit = "autoload -U promptinit && promptinit";
    };
    # mtr.enable = true;
    # gnupg.agent = { enable = true; enableSSHSupport = true; };
  };

  # List services that you want to enable:
  # Enable/disable the OpenSSH daemon.
  services.openssh.enable = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";

    # Enable touchpad support.
    libinput.enable = true;

    # Use XMonad as the window manager.
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
        haskellPackages.xmonad
      ];
    };
    windowManager.default = "xmonad";
    desktopManager = {
      xterm.enable = false;
      default = "none";
    };

    displayManager = {
      sessionCommands = lib.mkAfter
      ''
        ${pkgs.xorg.xset}/bin/xset r rate 300 44
        ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
        ${pkgs.numlockx} on
        ${pkgs.feh}/bin/feh --no-fehbg --bg-fill /home/luc/.xmonad/wallpaper.png
      '';
      slim = {
        enable = true;
        defaultUser = "luc";
      };
    };
  };

  # Display settings
  services.redshift = {
    enable = true;
    latitude = "50.8504500";
    longitude = "4.3487800";
    temperature = {
      day = 6500;
      night = 2700;
    };
  };

  # SSD settings (performance/maintenance)
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };
  fileSystems."/".options = [
    "noatime"      # Dont write read times back to disk (for longer SSD lifetime)
    "commit=1800"  # syncs every 30 mins
  ];

  services.urxvtd.enable = true;

  systemd.user.services."compton" = {
    enable = true;
    description = "";
    wantedBy = [ "default.target" ];
    path = [ pkgs.compton ];
    serviceConfig.Type = "forking";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.compton}/bin/compton -b -CG -d :0";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.luc = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

  nix = {
    extraOptions = ''
      build-cores = 4
    '';
    maxJobs = 4;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
}
