{ config, pkgs, lib, ... }:

let

  cfg = config.services.auto-rollback;

in {

  options.services.auto-rollback = {
    enable = lib.mkEnableOption "Enable auto-rollback of NixOS.";

    timeout = lib.mkOption {
      type = lib.types.str;
      default = "1min";
      example = lib.literalExample "10min";
      description = ''
        Sets the time it has to take between triggering deploy-prepare.target & deploy-healthy.target for an automatic rollback to occur.
      '';
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.auto-rollback-capture-system = {
      description = "Capture the current system profile for rollbacks";
      wantedBy = [ "deploy-prepare.target" ];
      path = [ pkgs.nix ];
      script = ''
        nix-store --add-root /nix/var/nix/profiles/system-rollback --indirect --realise /nix/var/nix/profiles/system
      '';
      serviceConfig.Type = "oneshot";
    };

    systemd.services.auto-rollback-automatic-rollback = {
      description = "Automatic rollback";
      restartIfChanged = false;
      path = [ pkgs.nix ];
      script = ''
        if [ -h /nix/var/nix/profiles/system-rollback ]; then
          echo "Automatic rollback reached, rolling back.."
          exec /nix/var/nix/profiles/system-rollback/bin/switch-to-configuration switch
        fi
      '';
      serviceConfig.Type = "oneshot";
    };

    systemd.timers.auto-rollback-automatic-rollback = {
      enable = true;
      wantedBy = [ "deploy-prepare.target" ];
      unitConfig = {
        X-RestartIfChanged = "False";
        X-ReloadIfChanged = "False";
        Conflicts = [ "deploy-healthy.target" ];
      };
      timerConfig = {
        OnActiveSec = cfg.timeout;
        RemainAfterElapse = false;
      };
    };

    systemd.targets.deploy-healthy.unitConfig.OnFailure = "auto-rollback-automatic-rollback.service";

  };

}
