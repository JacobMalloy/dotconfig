{ config, pkgs, lib, ... }:

{

  users.users.jmalloy = {
    isNormalUser = true;
    description = "Jacob Malloy";
    shell = pkgs.zsh;
    hashedPassword="$6$Mt1..jrvHr8Zc0zV$UPOUV3Ui4FBtoQcN7SsqybBvDwzSasbKnHlOfNtLgQ1WCUK2F7RU3tGUfHKiBBFZ7BZGlRrjqzW2io0gxlGpk/";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };
}
