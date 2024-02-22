{ config, pkgs, lib, ... }:

{

  users.users.jmalloy = {
    isNormalUser = true;
    description = "Jacob Malloy";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };
}
