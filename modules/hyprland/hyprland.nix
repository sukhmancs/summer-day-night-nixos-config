{
  config,
  lib,
  pkgs,
  hyprland,
  hyprlock,
  hypridle,
  vars,
  host,
  ...
}: let
  colors = import ../theming/colors.nix;
  mainMod = "SUPER"; # Define your main modifier key
in
  with lib;
  with host; {
    options = {
      hyprland = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };

    config = mkIf config.hyprland.enable {
      environment = let
        exec = "exec dbus-launch Hyprland";
      in {
        loginShellInit = ''
          if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
            ${exec}
          fi
        '';

        variables = {
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
        };

        sessionVariables =
          if hostName == "work"
          then {
            HYPRLAND_LOG_WLR = "1";
            _JAVA_AWT_WM_NONREPARENTING = "1";
            WLR_NO_HARDWARE_CURSORS = "1";
            MOZ_ENABLE_WAYLAND = "1";
            QT_QPA_PLATFORMTHEME = "qt5ct";
            LIBVA_DRIVER_NAME = "nvidia";
            GBM_BACKEND = "nvidia-drm";
            GDK_BACKEND = "wayland,x11";
          }
          else {
            HYPRLAND_LOG_WLR = "1";
            _JAVA_AWT_WM_NONREPARENTING = "1";
            WLR_NO_HARDWARE_CURSORS = "1";
            MOZ_ENABLE_WAYLAND = "1";
            QT_QPA_PLATFORMTHEME = "qt5ct";
            LIBVA_DRIVER_NAME = "nvidia";
            GBM_BACKEND = "nvidia-drm";
          };
        systemPackages = with pkgs; [
          grimblast # Screenshot
          hyprpaper # Wallpaper
          wl-clipboard # Clipboard
          wlr-randr # Monitor Settings
          xwayland # X session
        ];
      };
      home-manager.users.${vars.user} = {
        wayland.windowManager.hyprland = {
          enable = true;
          package = hyprland.packages.${pkgs.system}.hyprland;
          xwayland.enable = true;
          settings = {
            exec-once = [
              "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "${pkgs.ckb-next}/bin/ckb-next -b"
              "${hyprland.packages.${pkgs.system}.hyprctl}/bin/hyprctl setcursor Bibata-Modern-Classic 24"
              "/usr/lib/polkit-kde-authentication-agent-1"
              "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch cliphist store"
              "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch cliphist store"
              "sleep 3 && /usr/lib/kdeconnectd"
            ];

            general = {
              cursor_inactive_timeout = 0;
            };

            input = {
              kb_layout = "us,us";
              kb_variant = "dvorak,";
              # kb_options=caps:ctrl_modifier
              kb_options = "grp:alt_space_toggle";
              numlock_by_default = true;
              follow_mouse = 1;
              touchpad = {
                natural_scroll = true;
              };
              sensitivity = 0;
            };

            gestures = {
              workspace_swipe = true;
              workspace_swipe_distance = 400;
              workspace_swipe_invert = true;
              workspace_swipe_min_speed_to_force = 30;
              workspace_swipe_cancel_ratio = 0.5;
              workspace_swipe_create_new = false;
              workspace_swipe_forever = true;
            };

            master = {
              new_is_master = true;
            };

            binds = {
              workspace_back_and_forth = true;
            };

            misc = {
              layers_hog_keyboard_focus = true;
              focus_on_activate = true;
            };

            layerrule = "noanim,selection";

            windowrule = [
              "maxsize 600 800, ^(pavucontrol)$"
              "center, ^(pavucontrol)$"
              "float, ^(pavucontrol)$"
              "tile, ^(libreoffice)$"
              "float, ^(blueman-manager)$"
              "nofullscreenrequest, ^(.*libreoffice.*)$"
              "size 490 600, ^(org.gnome.Calculator)$"
              "float, ^(org.gnome.Calculator)$"
              "float, ^(org.kde.polkit-kde-authentication-agent-1)$"
              "float, title:^(Confirm to replace files)$"
              "float, title:^(File Operation Progress)$"
              "center, ^(eog)$"
              "center, ^(vlc)$"
              "float, ^(eog)$"
              "float, ^(vlc)$"
              "float, ^(imv)$"
              "float, title:^(Steam - News)$"
            ];

            bind = [
              "${mainMod}, return, exec, ${pkgs.kitty}/bin/kitty"
              "${mainMod}, Q, killactive,"
              "${mainMod}, M, exit,"
              "${mainMod}, E, exec, ${pkgs.thunar}/bin/thunar"
              "${mainMod}, G, togglegroup"
              "${mainMod}SHIFT, G, moveoutofgroup"
              "${mainMod}CTRL, G, moveintogroup, r"
              "${mainMod}, F, fullscreen,"
              "${mainMod}, A, movetoworkspace, special"
              "SUPER_SHIFT, R, exec, ${hyprland.packages.${pkgs.system}.hyprctl}/bin/hyprctl reload"
              "${mainMod}, P, pseudo,"
              "${mainMod}, J, togglesplit,"
              "${mainMod}, W, exec, eww open --toggle overview  && eww update selected=_none"
              "${mainMod}, O, exec, grim -g \"$(${pkgs.slurp}/bin/slurp)\" \"tmp.png\" && tesseract \"tmp.png\" - | ${pkgs.wl-clipboard}/bin/wl-copy && rm \"tmp.png\""
              "${mainMod}, N, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t"
              "${mainMod}, K, exec, ~/.config/hypr/scripts/switch-layout.sh"
              "${mainMod}, U, layoutmsg, swapwithmaster"
              "ALT, F10, pass, ^(com\\.obsproject\\.Studio)$"
              "ALT, Tab, focuscurrentorlast"
              "${mainMod}, SPACE, togglefloating"
              ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-"
              ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +10%"
              ", XF86AudioRaiseVolume, exec, ${pkgs.pulseaudioFull}/bin/pactl -- set-sink-volume @DEFAULT_SINK@ +5%"
              ", XF86AudioRaiseVolume, exec, sh $HOME/.config/hypr/scripts/notify-volume.sh"
              ", XF86AudioLowerVolume, exec, ${pkgs.pulseaudioFull}/bin/pactl -- set-sink-volume @DEFAULT_SINK@ -5%"
              ", XF86AudioLowerVolume, exec, sh $HOME/.config/hypr/scripts/notify-volume.sh"
              ", XF86AudioMute, exec, ${pkgs.pulseaudioFull}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
              ", XF86AudioMute, exec, sh $HOME/.config/hypr/scripts/notify-volume.sh"
              "${mainMod}, H, exec, sh $HOME/.config/hypr/scripts/toggle-gaps.sh"
              "${mainMod}, Tab, changegroupactive"
              "${mainMod}, F11, exec, ${config.programs.hyprland.package}/bin/hyprctl keyword monitor DP-2,3840x2160@60,0x0,1.25"
              "${mainMod}, F12, exec, ${config.programs.hyprland.package}/bin/hyprctl keyword monitor DP-2,3840x2160@60,0x0,1"
              "${mainMod}, left, movefocus, l"
              "${mainMod}, right, movefocus, r"
              "${mainMod}, up, movefocus, u"
              "${mainMod}, down, movefocus, d"
              "${mainMod}, MINUS, workspace, special"
              "${mainMod}, 1, workspace, 1"
              "${mainMod}, 2, workspace, 2"
              "${mainMod}, 3, workspace, 3"
              "${mainMod}, 4, workspace, 4"
              "${mainMod}, 5, workspace, 5"
              "${mainMod}, 6, workspace, 6"
              "${mainMod}, 7, workspace, 7"
              "${mainMod}, 8, workspace, 8"
              "${mainMod}, 9, workspace, 9"
              "${mainMod}, 0, workspace, 10"
              "${mainMod} SHIFT, 1, movetoworkspace, 1"
              "${mainMod} SHIFT, 2, movetoworkspace, 2"
              "${mainMod} SHIFT, 3, movetoworkspace, 3"
              "${mainMod} SHIFT, 4, movetoworkspace, 4"
              "${mainMod} SHIFT, 5, movetoworkspace, 5"
              "${mainMod} SHIFT, 6, movetoworkspace, 6"
              "${mainMod} SHIFT, 7, movetoworkspace, 7"
              "${mainMod} SHIFT, 8, movetoworkspace, 8"
              "${mainMod} SHIFT, 9, movetoworkspace, 9"
              "${mainMod} SHIFT, 0, movetoworkspace, 10"
              "${mainMod} CTRL, 1, movetoworkspacesilent, 1"
              "${mainMod} CTRL, 2, movetoworkspacesilent, 2"
              "${mainMod} CTRL, 3, movetoworkspacesilent, 3"
              "${mainMod} CTRL, 4, movetoworkspacesilent, 4"
              "${mainMod} CTRL, 5, movetoworkspacesilent, 5"
              "${mainMod} CTRL, 6, movetoworkspacesilent, 6"
              "${mainMod} CTRL, 7, movetoworkspacesilent, 7"
              "${mainMod} CTRL, 8, movetoworkspacesilent, 8"
              "${mainMod} CTRL, 9, movetoworkspacesilent, 9"
              "${mainMod} CTRL, 0, movetoworkspacesilent, 10"
              "${mainMod}, XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
              "${mainMod}, XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
              "${mainMod}, XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
              "${mainMod}, Print, exec, $HOME/.config/hypr/scripts/freeze-screenshot.sh 0"
              ", Print, exec, $HOME/.config/hypr/scripts/freeze-screenshot.sh 1"
              "CTRL, Print, exec, grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.swappy}/bin/swappy -f -"
            ];
          };
        };
      };
    };
  }
