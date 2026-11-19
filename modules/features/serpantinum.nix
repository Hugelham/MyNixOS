{ inputs, self, ... }: {
  flake.nixosModules.serpantinum = { config, pkgs, lib, ... }: let

    settings = builtins.fromJSON (builtins.readFile ./settings.json);

    defaultsJson = pkgs.writeText "serpantinum-defaults.json" (builtins.toJSON settings);

    hm_config = {
      imports = [ inputs.serpantinum.homeManagerModules.default ];
      home.stateVersion = config.system.stateVersion;
      programs.serpantinum = {
      enable = true;
      systemd.enable = true;
      inherit settings;
      };
    };

  in {
    imports = [
      inputs.serpantinum.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
    ];

    programs.serpantinum.enable = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.daniel = hm_config;
    };

    systemd.user.services.serpantinum-defaults = {
      description = "Seed default serpantinum settings";
      wantedBy = [ "default.target" ];
      path = [ pkgs.jq ];
      serviceConfig.Type = "oneshot";
      script = ''
        for i in $(seq 40); do [ -d "$HOME" ] && break; sleep 0.25; done
        dst="''${XDG_CONFIG_HOME:-$HOME/.config}/serpantinum/settings.json"
        if [ ! -e "$dst" ]; then
          mkdir -p "$(dirname "$dst")"
          jq --arg w "$HOME/Pictures/Wallpapers" '.wallpaperDir = $w' ${defaultsJson} > "$dst"
        fi
      '';
    };
  };
}