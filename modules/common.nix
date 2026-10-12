{ config, pkgs, ... }:

{
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDF5Ti/vojxgZD0a50a7rsfEHvEBKfmuOltQbUisr0QN966RKJK422b8robGUzG/FJIi7oJVYkqN82xHOeez967d2MIrDRCRhk32n5Tc4HLkZYsD8zskY1Sg0ivyumuDprDccFI10JVNq2nDQInKRE95/Gdp+D35ndScQH62hQyHSrBB9Exgq/OUZx0gvb/olnzmmonPVQz/6JoMoQ+DuHkhlVY5e8bruQqsSfABpLyc1uOciEACBuvVjO+PtOgVyCGYOqN9lKnOKcfWCm96/rtobg9bKCK7oVgfju02cXfabxuiomoYr8wsjuSIAgbAm7Wu2JiFmFwL3z23C5AbKu/bZwPnvjxW/KahHs06vpbxqS20bLN9ROqt9vgY7sg3apBguAja03koYCEVWmOaB3vd5dU+mSjqjJlAlSBQLdWtFNOR12Pg0PjFQJqo4LnC2fxrhFvzVFuerHWSVGlU/MwI7cC1VkvfOFnEHnUlLMAzL9z90p8xfYJvPpQjCbALc85o0TaM/qm/n7ffp6sB9/MK8slszIasQVAst4mJjL6lKPDuN37fzi2YFzRbTor2ptxJbo+MhmfM0RETRb3AuI17tqjFn8/4j2+AaxD1lyG5j8vUnCtd0ZKuk907F19fLmKF7DQOGUIrtp47jEN0/zYLCQQeqQ6vEg+xVJQwjQc/Q== cardno:23_839_811"
  ];

  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  environment.systemPackages = with pkgs; [ vim git curl wget htop ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  services.comin = {
    enable = true;
    remotes = [{
      name = "origin";
      url = "https://github.com/Aegis2D-Dev/infra-config.git";
      branches.main.name = "master";
    }];
  };
}
