{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
     enable = true;
     package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
  };
};  

  flake.wrappersModules.niri = {
    config,
    lib,
    pkgs,
    ...
  }: let
    workspaceBinds = lib.concatMapStringsSep "\n" (n: let
      key =
        if n == 10
        then "0"
        else toString n;
    in ''
      Mod+${key} { spawn "serpantinum" "msg" "workspace" "${toString n}"; }
      Mod+Shift+${key} { spawn "serpantinum" "msg" "workspace" "${toString n}" "move"; }
    '') (lib.range 1 10);

    wlPaste = "${config.pkgs.wl-clipboard}/bin/wl-paste";
    cliphist = lib.getExe config.pkgs.cliphist;
  in {
    options.terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
    };

    config."config.kdl".content = lib.mkForce ''
      prefer-no-csd

      input {
          focus-follows-mouse
          keyboard {
              xkb {
                  layout "us"
                  options "caps:escape"
              }
              repeat-rate 40
              repeat-delay 250
          }
          touchpad {
              tap
              natural-scroll
          }
          mouse {
              accel-profile "flat"
          }
      }

      layout {
          gaps 5
      }

      xwayland-satellite {
          path "${lib.getExe config.pkgs.xwayland-satellite}"
      }

      spawn-at-startup "bash" "-c" "${wlPaste} --type text --watch ${cliphist} store"
      spawn-at-startup "bash" "-c" "${wlPaste} --type image --watch ${cliphist} store"

      binds {
          Mod+Return { spawn "${config.terminal}"; }
          Mod+Shift+E { quit; }

          Mod+Q { close-window; }
          Mod+F { maximize-column; }
          Mod+G { fullscreen-window; }
          Mod+Shift+F { toggle-window-floating; }
          Mod+Shift+C { center-column; }

          Mod+Left { focus-column-left; }
          Mod+Right { focus-column-right; }
          Mod+Up { focus-window-up; }
          Mod+Down { focus-window-down; }

          Mod+Shift+Left { move-column-left; }
          Mod+Shift+Right { move-column-right; }
          Mod+Shift+Up { move-window-up; }
          Mod+Shift+Down { move-window-down; }

          Mod+Ctrl+H { set-column-width "-5%"; }
          Mod+Ctrl+L { set-column-width "+5%"; }
          Mod+Ctrl+J { set-window-height "-5%"; }
          Mod+Ctrl+K { set-window-height "+5%"; }

          Mod+WheelScrollDown { focus-column-left; }
          Mod+WheelScrollUp { focus-column-right; }
          Mod+Ctrl+WheelScrollDown { focus-workspace-down; }
          Mod+Ctrl+WheelScrollUp { focus-workspace-up; }

          Mod+D { spawn "serpantinum" "msg" "toggle" "launcher"; }
          Mod+B { spawn "serpantinum" "msg" "toggle" "system"; }
          Mod+C { spawn "serpantinum" "msg" "toggle" "clipboard"; }
          Mod+M { spawn "serpantinum" "msg" "toggle" "music"; }
          Mod+W { spawn "serpantinum" "msg" "toggle" "wallpaper"; }
          Mod+S { spawn "serpantinum" "msg" "toggle" "calendar"; }
          Mod+N { spawn "serpantinum" "msg" "toggle" "network"; }
          Mod+V { spawn "serpantinum" "msg" "toggle" "volume"; }
          Mod+H { spawn "serpantinum" "msg" "toggle" "settings"; }

          Mod+L { spawn "serpantinum" "lock"; }
          Mod+R { spawn "serpantinum" "reload"; }
          Mod+A { spawn "serpantinum" "msg" "bar" "autohide"; }
          Print { spawn "serpantinum" "screenshot"; }
          Shift+Print { spawn "serpantinum" "screenshot" "--edit"; }
          Ctrl+Print { spawn "serpantinum" "screenshot" "--full"; }

          XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%+"; }
          XF86AudioLowerVolume { spawn "wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%-"; }
          XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

          ${workspaceBinds}
      }
    '';
  };

  perSystem = {pkgs, ...}: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri];
    };
  };
}
