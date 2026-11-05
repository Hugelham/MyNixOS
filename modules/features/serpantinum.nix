{ inputs, self, ... }: {

  flake.nixosModules.serpantinum = { config, pkgs, ... }: {
    imports = [
      inputs.serpantinum.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
    ];

    programs.serpantinum.enable = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.daniel = {
        imports = [ inputs.serpantinum.homeManagerModules.default ];

        home.stateVersion = config.system.stateVersion;

        programs.serpantinum = {
          enable = true;
          systemd.enable = true;
          settings = {
            wallpaperDir = "/home/daniel/Pictures/Wallpapers";
            general = {
              language = "en";
              weatherUnit = "imperial";
              weatherInterval = 30;
            };
            bar = {
              position = "top";
              style = "solid";
              width = 40;
              workspaceCount = 10;
              modules = {
                left = [ "workspaces" ];
                center = [ "time" ];
                right = [ "tray" [ "kb" "wifi" "bt" "vol" "bat" ] ];
              };
            };
            theme = {
              fontFamily = "Adwaita Mono";
              borderRadius = 12;
              matugen = true;
            };
            notifications = {
              dnd = false;
              position = "top right";
              sound = true;
            };
          };
        };
      };
    };
  };

}
