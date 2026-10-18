{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.linuxConfig.home;
  fcitx5WithMozc = pkgs.qt6Packages.fcitx5-with-addons.override {
    addons = [ pkgs.fcitx5-mozc ];
  };
  themeDefaults = import ../quickshell-theme.nix;
  quickshellConfig = pkgs.callPackage ../packages/quickshell-config.nix {
    theme = cfg.quickshell.theme;
  };
  quickshellRoot = "${quickshellConfig}/quickshell";
  opaqueColor =
    color: if builtins.stringLength color == 9 then "#${builtins.substring 3 6 color}" else color;
  btopTheme = ''
    # btop theme matching quickshell/shared/Theme.js

    theme[main_bg]="${opaqueColor cfg.quickshell.theme.background}"
    theme[main_fg]="${cfg.quickshell.theme.text}"
    theme[title]="${cfg.quickshell.theme.accent}"
    theme[hi_fg]="${cfg.quickshell.theme.warning}"
    theme[selected_bg]="${cfg.quickshell.theme.buttonHover}"
    theme[selected_fg]="${cfg.quickshell.theme.white}"
    theme[inactive_fg]="${cfg.quickshell.theme.muted}"
    theme[proc_misc]="${cfg.quickshell.theme.accent}"

    theme[cpu_box]="${cfg.quickshell.theme.border}"
    theme[mem_box]="${cfg.quickshell.theme.border}"
    theme[net_box]="${cfg.quickshell.theme.border}"
    theme[proc_box]="${cfg.quickshell.theme.border}"
    theme[div_line]="${cfg.quickshell.theme.border}"

    theme[temp_start]="${cfg.quickshell.theme.success}"
    theme[temp_mid]="${cfg.quickshell.theme.warning}"
    theme[temp_end]="${cfg.quickshell.theme.danger}"

    theme[cpu_start]="${cfg.quickshell.theme.success}"
    theme[cpu_mid]="${cfg.quickshell.theme.accent}"
    theme[cpu_end]="${cfg.quickshell.theme.danger}"

    theme[free_start]="${cfg.quickshell.theme.success}"
    theme[free_mid]="${cfg.quickshell.theme.accent}"
    theme[free_end]="${cfg.quickshell.theme.danger}"

    theme[cached_start]="${cfg.quickshell.theme.muted}"
    theme[cached_mid]="${cfg.quickshell.theme.accent}"
    theme[cached_end]="${cfg.quickshell.theme.warning}"

    theme[available_start]="${cfg.quickshell.theme.success}"
    theme[available_mid]="${cfg.quickshell.theme.accent}"
    theme[available_end]="${cfg.quickshell.theme.warning}"

    theme[used_start]="${cfg.quickshell.theme.accent}"
    theme[used_mid]="${cfg.quickshell.theme.warning}"
    theme[used_end]="${cfg.quickshell.theme.danger}"

    theme[download_start]="${cfg.quickshell.theme.muted}"
    theme[download_mid]="${cfg.quickshell.theme.accent}"
    theme[download_end]="${cfg.quickshell.theme.white}"

    theme[upload_start]="${cfg.quickshell.theme.muted}"
    theme[upload_mid]="${cfg.quickshell.theme.success}"
    theme[upload_end]="${cfg.quickshell.theme.white}"
  '';
  wofiStyle = ''
    window {
      background-color: rgba(20, 20, 20, 0.96);
      border-radius: 12px;
      border: 1px solid ${cfg.quickshell.theme.border};
      padding: 8px;
    }

    #input {
      background-color: rgba(255, 255, 255, 0.07);
      color: white;
      border-radius: 8px;
      border: none;
      padding: 6px 10px;
      font-size: 14px;
    }

    #input:focus {
      color: ${cfg.quickshell.theme.white};
      border: 1px solid #5f73d9;
      box-shadow: 0 0 6px rgba(95, 115, 217, 0.35);
      background-color: rgba(255, 255, 255, 0.12);
    }

    #entry {
      border-radius: 6px;
      padding: 6px 10px;
      margin: 2px 0;
    }

    #entry:selected {
      background-color: ${cfg.quickshell.theme.border};
      color: ${cfg.quickshell.theme.accent};
    }

    #text {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 14px;
      color: white;
    }
  '';

  renderText =
    text:
    builtins.replaceStrings
      [
        "@LINUX_CONFIG_DIR@"
        "@HOME@"
      ]
      [
        (toString quickshellConfig)
        config.home.homeDirectory
      ]
      text;
  render = source: renderText (builtins.readFile source);
  renderHyprland =
    source:
    renderText (
      builtins.replaceStrings
        [
          "exec-once = @LINUX_CONFIG_DIR@/quickshell/run.sh --no-duplicate --daemonize"
          "exec-once = hypridle"
          "exec-once = nm-applet --indicator"
          "exec-once = awww-daemon & awww img @LINUX_CONFIG_DIR@/sddm/mysddm/pictures/wallpapers/v1.jpg"
          "exec-once = fcitx5"
          "exec-once = wl-paste --type text --watch cliphist store"
          "exec-once = wl-paste --type image --watch cliphist store"
        ]
        [
          "exec-once = ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && ${pkgs.systemd}/bin/systemctl --user start linux-config-session.target"
          ""
          ""
          ""
          ""
          ""
          ""
        ]
        (builtins.readFile source)
    );
in
{
  options.linuxConfig.home = {
    enable = lib.mkEnableOption "the Linux desktop Home Manager profile";
    username = lib.mkOption {
      type = lib.types.strMatching "[a-z_][a-z0-9_-]*";
      default = "atolix";
      description = "The Unix user receiving the desktop profile";
    };
    git.name = lib.mkOption {
      type = lib.types.str;
      default = "atolix";
      description = "Git author name";
    };
    git.email = lib.mkOption {
      type = lib.types.str;
      default = "82761106+atolix@users.noreply.github.com";
      description = "Git author email";
    };
    quickshell.executable = lib.mkOption {
      type = lib.types.strMatching "/.+";
      default = "${pkgs.quickshell}/bin/quickshell";
      description = "Absolute path to the Quickshell executable";
    };
    quickshell.theme = lib.mapAttrs (
      name: default:
      lib.mkOption {
        inherit default;
        type = lib.types.strMatching "#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?";
        description = "Quickshell ${name} theme color";
      }
    ) themeDefaults;
  };

  config = lib.mkIf cfg.enable {
    programs.home-manager.enable = true;
    programs.git = {
      enable = true;
      settings.user = {
        name = cfg.git.name;
        email = cfg.git.email;
      };
    };
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files";
    };
    programs.fastfetch = {
      enable = true;
      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
        logo.color = {
          "1" = cfg.quickshell.theme.accent;
          "2" = cfg.quickshell.theme.text;
        };
        display.color = {
          keys = cfg.quickshell.theme.accent;
          title = cfg.quickshell.theme.accent;
          output = cfg.quickshell.theme.text;
          separator = cfg.quickshell.theme.muted;
        };
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "display"
          "de"
          "wm"
          "wmtheme"
          "theme"
          "icons"
          "font"
          "cursor"
          "terminal"
          "terminalfont"
          "cpu"
          "gpu"
          "memory"
          "swap"
          "disk"
          "battery"
          "poweradapter"
          "locale"
          "break"
          "colors"
        ];
      };
    };
    programs.eza = {
      enable = true;
      enableZshIntegration = false;
    };
    programs.mise = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.ripgrep.enable = true;
    programs.ghostty = {
      enable = true;
      settings = {
        config-file = "${config.home.homeDirectory}/dotfiles/ghostty/config";
      };
    };
    programs.mpv = {
      enable = true;
      config = {
        vo = "gpu-next";
        hwdec = "auto-safe";
        save-position-on-quit = true;
        keep-open = true;
        osd-font = "JetBrainsMono Nerd Font Mono";
        osd-font-size = 24;
      };
    };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];
      shellAliases = {
        nv = "nvim";
        ":q" = "exit";
        ls = "eza -l -a --no-user";
        gco = "git checkout";
        canv = "glslViewer -l";
      };
      initContent = lib.mkMerge [
        (lib.mkBefore ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        '')
        ''
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        ''
      ];
    };
    fonts.fontconfig.enable = true;
    home.pointerCursor = {
      enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
    gtk = {
      enable = true;
      theme.name = "Adwaita-dark";
      iconTheme.name = "Adwaita";
      font = {
        name = "JetBrainsMono Nerd Font Mono";
        size = 10;
      };
      gtk3 = {
        extraConfig = {
          gtk-application-prefer-dark-theme = true;
          gtk-toolbar-style = "GTK_TOOLBAR_ICONS";
          gtk-toolbar-icon-size = "GTK_ICON_SIZE_SMALL_TOOLBAR";
          gtk-button-images = false;
          gtk-menu-images = false;
          gtk-enable-animations = false;
          gtk-decoration-layout = "menu:close";
          gtk-primary-button-warps-slider = false;
        };
        extraCss = builtins.readFile ../../home/atolix/.config/gtk-3.0/gtk.css;
      };
    };
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "video/mp4" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "video/quicktime" = [ "mpv.desktop" ];
        "video/mpeg" = [ "mpv.desktop" ];
      };
    };

    home.packages = with pkgs; [
      awww
      brightnessctl
      btop
      cliphist
      codex
      fcitx5WithMozc
      glslviewer
      google-chrome
      grim
      hypridle
      hyprlock
      lm_sensors
      lua-language-server
      gopls
      neovim
      networkmanager
      networkmanagerapplet
      nerd-fonts.jetbrains-mono
      noto-fonts
      procps
      pulseaudio
      python3
      slurp
      solargraph
      thunar
      typescript
      typescript-language-server
      upower
      wf-recorder
      wireplumber
      wl-clipboard
      wofi
      rust-analyzer
      zls
    ];

    xdg.configFile = {
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
      "herdr/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/herdr/config.toml";
      "hypr/hyprland.conf".text = renderHyprland ../../home/atolix/.config/hypr/hyprland.conf;
      "hypr/hyprlock.conf".text = render ../../home/atolix/.config/hypr/hyprlock.conf;
      "hypr/hypridle.conf".text = render ../../quickshell/hypridle.conf;
      "hypr/hyprland-osd.conf".text = render ../../quickshell/hyprland-osd.conf;

      "wofi/style.css".text = wofiStyle;
      "btop/btop.conf".text = render ../../home/atolix/.config/btop/btop.conf;
      "btop/themes/linux-config.theme".text = btopTheme;

      "fcitx5/config".text = render ../../home/atolix/.config/fcitx5/config;
      "fcitx5/profile".text = render ../../home/atolix/.config/fcitx5/profile;
      "fcitx5/conf/notifications.conf".text =
        render ../../home/atolix/.config/fcitx5/conf/notifications.conf;
    };

    home.file.".p10k.zsh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/p10k.zsh";

    systemd.user.services.linux-config-quickshell = {
      Unit = {
        Description = "linux-config Quickshell desktop shell";
        PartOf = [ "linux-config-session.target" ];
      };
      Service = {
        Environment = "LINUX_CONFIG_QUICKSHELL_BIN=${cfg.quickshell.executable}";
        ExecStart = "${cfg.quickshell.executable} --path ${quickshellRoot} --no-duplicate";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "linux-config-session.target" ];
    };

    systemd.user.services.linux-config-hypridle = {
      Unit = {
        Description = "linux-config Hypridle daemon";
        PartOf = [ "linux-config-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "linux-config-session.target" ];
    };

    systemd.user.services.linux-config-wallpaper = {
      Unit = {
        Description = "linux-config wallpaper daemon";
        PartOf = [ "linux-config-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        ExecStartPost = "${pkgs.awww}/bin/awww img ${quickshellConfig}/sddm/mysddm/pictures/wallpapers/v1.jpg";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "linux-config-session.target" ];
    };

    systemd.user.services.linux-config-network-manager-applet = {
      Unit = {
        Description = "linux-config NetworkManager applet";
        PartOf = [ "linux-config-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "linux-config-session.target" ];
    };

    systemd.user.services.linux-config-fcitx5 = {
      Unit = {
        Description = "linux-config Fcitx5 input method";
        PartOf = [ "linux-config-session.target" ];
      };
      Service = {
        ExecStart = "${fcitx5WithMozc}/bin/fcitx5";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "linux-config-session.target" ];
    };

    systemd.user.services.linux-config-clipboard-text = {
      Unit = {
        Description = "linux-config text clipboard history";
        PartOf = [ "linux-config-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "linux-config-session.target" ];
    };

    systemd.user.services.linux-config-clipboard-image = {
      Unit = {
        Description = "linux-config image clipboard history";
        PartOf = [ "linux-config-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "linux-config-session.target" ];
    };

    systemd.user.targets.linux-config-session.Unit.Description =
      "linux-config graphical session services";

    home.sessionVariables.LINUX_CONFIG_QUICKSHELL = quickshellRoot;
    home.sessionVariables.LINUX_CONFIG_QUICKSHELL_BIN = cfg.quickshell.executable;
  };
}
