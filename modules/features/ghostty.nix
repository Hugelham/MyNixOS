{ ... }: {
  flake.nixosModules.ghostty = { pkgs, lib, ... }: let
    shader = pkgs.fetchurl {
      url = "https://github.com/sahaj-b/ghostty-cursor-shaders/raw/88c27a55b2e970eec19c21ef858a1a5bea489a1d/cursor_warp.glsl";
      sha256 = "sha256-9ZlLcNu5cH0Ibc7qrS+lfrY4neesQm/5FdTCNa85G+s=";
    };

    settings = {
      custom-shader = "${shader}";
      custom-shader-animation = "always";
      term = "xterm-256color";
      confirm-close-surface = "false";
      font-family = "Adwaita Mono";
      font-size = 12;
      theme = "Catppuccin Mocha";
      adjust-cell-height = "10%";
      window-theme = "dark";
      window-height = "32";
      window-width = "110";
      background-opacity = "0.20";
      background-blur-radius = "40";
      selection-background = "#2d3f76";
      selection-foreground = "#c8d3f5";
      cursor-style = "bar";
      mouse-hide-while-typing = "true";
      wait-after-command = "false";
      shell-integration = "detect";
      window-save-state = "always";
      gtk-single-instance = "true";
      unfocused-split-opacity = "0.5";
      quick-terminal-position = "center";
      shell-integration-features = "cursor,sudo";
      bold-is-bright = "false";
      focus-follows-mouse = "true";
      resize-overlay = "never";
      keybind = [
        "clear"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+plus=increase_font_size:1"
        "ctrl+shift+minus=decrease_font_size:1"
        "ctrl+shift+zero=reset_font_size"
        "alt+s>r=reload_config"
        "alt+s>x=close_surface"
        "alt+s>n=new_window"
        "alt+s>c=new_tab"
        "alt+s>shift+l=next_tab"
        "alt+s>shift+h=previous_tab"
        "alt+s>comma=move_tab:-1"
        "alt+s>period=move_tab:1"
        "alt+s>1=goto_tab:1"
        "alt+s>2=goto_tab:2"
        "alt+s>3=goto_tab:3"
        "alt+s>4=goto_tab:4"
        "alt+s>5=goto_tab:5"
        "alt+s>6=goto_tab:6"
        "alt+s>7=goto_tab:7"
        "alt+s>8=goto_tab:8"
        "alt+s>9=goto_tab:9"
        "alt+s>\\=new_split:right"
        "alt+s>-=new_split:down"
        "alt+s>j=goto_split:bottom"
        "alt+s>k=goto_split:top"
        "alt+s>h=goto_split:left"
        "alt+s>l=goto_split:right"
        "alt+s>z=toggle_split_zoom"
        "alt+s>e=equalize_splits"
      ];
    };

    lines = lib.concatLists (lib.mapAttrsToList
      (k: v:
        if builtins.isList v
        then map (x: "${k} = ${x}") v
        else [ "${k} = ${toString v}" ])
      settings);
  in {
    environment.etc."ghostty/config".text = lib.concatStringsSep "\n" lines + "\n";

    systemd.user.services.ghostty-defaults = {
      description = "Seed ghostty user config";
      wantedBy = [ "default.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        for i in $(seq 40); do [ -d "$HOME" ] && break; sleep 0.25; done
        dst="''${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
        if [ ! -e "$dst" ]; then
          mkdir -p "$(dirname "$dst")"
          echo "config-file = /etc/ghostty/config" > "$dst"
        fi
      '';
    };
  };
}