{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    coreutils
    python3
    xdg_utils
    xclip
    xorg.xbacklight
    xorg.xset
    numlockx
    compton
    rxvt_unicode
    urxvt_perls
    scrot
    haskellPackages.xmobar
    dmenu
    which
    curl
    wget
    file
    tree
    lsof
    htop
    zip
    unzip
    gnumake
    vim_configurable
    emacs
    gitAndTools.gitFull
    chromium
  ];
}

