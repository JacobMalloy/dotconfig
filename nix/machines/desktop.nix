# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  networking.hostName = "desktop"; # Define your hostname.
  imports = [
      ../nix_general.nix
      ../networking.nix
      ../gpg_agent.nix
      ../users/jmalloy.nix
      ../machine_hardware/desktop.nix
      ../nvidia.nix
      ../zsh.nix
      ../locale.nix
      ../graphical/general.nix
      ../graphical/gnome.nix
      ../services/tailscale.nix
      ../dev_env/c.nix
      ../dev_env/python.nix
      ../dev_env/perf.nix
      ../dev_env/latex.nix
      ../dev_env/tools.nix
      ../services/ssh.nix
    ];

  #need this for dual booting windows
  time.hardwareClockInLocalTime = true;

}
