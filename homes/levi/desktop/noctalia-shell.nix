{ flake-inputs, pkgs, config, lib, ... }:

let
  cfg = config.modules.noctalia-shell;
in
{
  imports = [ flake-inputs.noctalia-shell.homeModules.default ];

  options.modules.noctalia-shell = {
    enable = lib.mkEnableOption ''Install and configure Noctalia-shell.'';
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      pavucontrol # More advanced audio control
      networkmanagerapplet # has nm-connection-editor
    ];

    # Little hack to make the notification history not persist between restarts
    xdg.cacheFile."noctalia/notifications.json" = {
      force = true;
      text = lib.toJSON { notifications = []; };
    };

    programs.noctalia-shell = {
      enable = true;

      # Modified version of the built-in catppuccin with:
      # blue, mauve and lavender as main colors.
      colors = {
        mError = "#f38ba8";
        mHover = "#b4befe";
        mOnError = "#11111b";
        mOnHover = "#11111b";
        mOnPrimary = "#11111b";
        mOnSecondary = "#11111b";
        mOnSurface = "#cdd6f4";
        mOnSurfaceVariant = "#a3b4eb";
        mOnTertiary = "#11111b";
        mOutline = "#4c4f69";
        mPrimary = "#89b4fa";
        mSecondary = "#cba6f7";
        mShadow = "#11111b";
        mSurface = "#1e1e2e";
        mSurfaceVariant = "#313244";
        mTertiary = "#b4befe";
      };

      # Below command puts current runnning settings into a nix attrset into your clipboard
      # nix eval --impure --raw --expr "with import <nixpkgs> {}; lib.generators.toPretty {} (builtins.fromJSON ''$(noctalia-shell ipc call state all)'')" | wl-copy
      settings = {
        appLauncher = {
          autoPasteClipboard = false;
          clipboardWatchImageCommand = "";
          clipboardWatchTextCommand = "";
          clipboardWrapText = true;
          customLaunchPrefix = "";
          customLaunchPrefixEnabled = false;
          density = "default";
          enableClipPreview = true;
          enableClipboardHistory = true;
          enableSessionSearch = false;
          enableSettingsSearch = false;
          enableWindowsSearch = false;
          iconMode = "tabler";
          ignoreMouseInput = false;
          overviewLayer = true;
          pinnedApps = [ ];
          position = "center";
          screenshotAnnotationTool = "";
          showCategories = false;
          showIconBackground = false;
          sortByMostUsed = true;
          terminalCommand = "kitty -e";
          useApp2Unit = false;
          viewMode = "list";
        };
        audio = {
          cavaFrameRate = 60;
          mprisBlacklist = [ ];
          preferredPlayer = "firefox";
          visualizerType = "linear";
          volumeFeedback = false;
          volumeOverdrive = false;
          volumeStep = 5;
        };
        bar = {
          autoHideDelay = 500;
          autoShowDelay = 150;
          backgroundOpacity = 0.93;
          barType = "floating";
          capsuleColorKey = "none";
          capsuleOpacity = 1;
          density = "default";
          displayMode = "always_visible";
          floating = true;
          frameRadius = 12;
          frameThickness = 8;
          hideOnOverview = false;
          marginHorizontal = 4;
          marginVertical = 4;
          monitors = [ ];
          outerCorners = true;
          position = "top";
          screenOverrides = [ ];
          showCapsule = true;
          showOutline = false;
          useSeparateOpacity = true;
          widgets = {
            center = [
              {
                characterCount = 10;
                colorizeIcons = false;
                emptyColor = "secondary";
                enableScrollWheel = true;
                focusedColor = "primary";
                followFocusedScreen = false;
                groupedBorderOpacity = 1;
                hideUnoccupied = false;
                iconScale = 0.8;
                id = "Workspace";
                labelMode = "name";
                occupiedColor = "secondary";
                pillSize = 0.6000000000000001;
                showApplications = false;
                showBadge = true;
                showLabelsOnlyWhenOccupied = true;
                unfocusedIconsOpacity = 1;
              }
            ];
            left = [
              {
                icon = "rocket";
                iconColor = "none";
                id = "Launcher";
              }
              {
                blacklist = [ "Discord" ];
                chevronColor = "none";
                colorizeIcons = false;
                drawerEnabled = true;
                hidePassive = true;
                id = "Tray";
                pinned = [ "udiskie" ];
              }
              {
                colorizeIcons = false;
                hideMode = "transparent";
                id = "ActiveWindow";
                maxWidth = 145;
                scrollingMode = "hover";
                showIcon = true;
                textColor = "none";
                useFixedWidth = true;
              }
              {
                compactMode = false;
                compactShowAlbumArt = true;
                compactShowVisualizer = false;
                hideMode = "hidden";
                hideWhenIdle = false;
                id = "MediaMini";
                maxWidth = 400;
                panelShowAlbumArt = true;
                panelShowVisualizer = true;
                scrollingMode = "hover";
                showAlbumArt = true;
                showArtistFirst = false;
                showProgressRing = true;
                showVisualizer = true;
                textColor = "none";
                useFixedWidth = false;
                visualizerType = "linear";
              }
            ];
            right = [
              {
                capsLockIcon = "letter-c";
                hideWhenOff = true;
                id = "LockKeys";
                numLockIcon = "letter-n";
                scrollLockIcon = "letter-s";
                showCapsLock = true;
                showNumLock = true;
                showScrollLock = true;
              }
              {
                hideWhenZero = true;
                hideWhenZeroUnread = false;
                iconColor = "none";
                id = "NotificationHistory";
                showUnreadBadge = true;
                unreadBadgeColor = "primary";
              }
              {
                applyToAllMonitors = true;
                displayMode = "alwaysShow";
                iconColor = "none";
                id = "Brightness";
                textColor = "none";
              }
              {
                displayMode = "alwaysShow";
                iconColor = "none";
                id = "Volume";
                middleClickCommand = "pwvucontrol || pavucontrol";
                textColor = "none";
              }
              {
                displayMode = "alwaysHide";
                iconColor = "none";
                id = "Bluetooth";
                textColor = "none";
              }
              {
                displayMode = "alwaysHide";
                iconColor = "none";
                id = "Network";
                textColor = "none";
              }
              {
                id = "Spacer";
                width = 20;
              }
              {
                deviceNativePath = "__default__";
                displayMode = "graphic";
                hideIfIdle = false;
                hideIfNotDetected = true;
                id = "Battery";
                showNoctaliaPerformance = true;
                showPowerProfiles = true;
              }
              {
                clockColor = "none";
                customFont = "Noto Sans";
                formatHorizontal = "ddd, dd MMM ⧸ HH:mm";
                formatVertical = "HH mm - dd MM";
                id = "Clock";
                tooltipFormat = "yyyy-MM-dd ⧸ HH:mm:ss t";
                useCustomFont = true;
              }
              {
                colorizeDistroLogo = false;
                colorizeSystemIcon = "none";
                customIconPath = "";
                enableColorization = true;
                icon = "noctalia";
                id = "ControlCenter";
                useDistroLogo = true;
              }
            ];
          };
        };
        brightness = {
          brightnessStep = 5;
          enableDdcSupport = true;
          enforceMinimum = true;
        };
        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
          ];
        };
        colorSchemes = {
          darkMode = true;
          generationMethod = "tonal-spot";
          manualSunrise = "06:30";
          manualSunset = "18:30";
          monitorForColors = "";
          predefinedScheme = "Catppuccin";
          schedulingMode = "off";
          useWallpaperColors = false;
        };
        controlCenter = {
          cards = [
            {
              enabled = false;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = true;
              id = "brightness-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
            {
              enabled = false;
              id = "weather-card";
            }
          ];
          diskPath = "/";
          position = "close_to_bar_button";
          shortcuts = {
            left = [
              {
                enableOnStateLogic = false;
                generalTooltipText = "System Monitor";
                icon = "activity-heartbeat";
                id = "CustomButton";
                onClicked = "noctalia-shell ipc call systemMonitor toggle";
                onMiddleClicked = "";
                onRightClicked = "";
                showExecTooltip = false;
                stateChecksJson = "[]";
              }
              {
                id = "PowerProfile";
              }
              {
                id = "Bluetooth";
              }
              {
                enableOnStateLogic = false;
                generalTooltipText = "Network Settings";
                icon = "network";
                id = "CustomButton";
                onClicked = "noctalia-shell ipc call controlCenter toggle; nm-connection-editor";
                onMiddleClicked = "";
                onRightClicked = "";
                showExecTooltip = false;
                stateChecksJson = "[]";
              }
              {
                enableOnStateLogic = false;
                generalTooltipText = "Audio Settings";
                icon = "volume";
                id = "CustomButton";
                onClicked = "noctalia-shell ipc call controlCenter toggle; pavucontrol";
                onMiddleClicked = "";
                onRightClicked = "";
                showExecTooltip = false;
                stateChecksJson = "[]";
              }
            ];
            right = [
              {
                id = "NoctaliaPerformance";
              }
              {
                id = "Notifications";
              }
              {
                id = "KeepAwake";
              }
              {
                id = "NightLight";
              }
              {
                enableOnStateLogic = false;
                generalTooltipText = "Settings";
                icon = "settings";
                id = "CustomButton";
                onClicked = "noctalia-shell ipc call controlCenter toggle; noctalia-shell ipc call settings open";
                onMiddleClicked = "";
                onRightClicked = "";
                showExecTooltip = false;
                stateChecksJson = "[]";
              }
            ];
          };
        };
        desktopWidgets = {
          enabled = false;
          gridSnap = false;
          monitorWidgets = [ ];
        };
        dock = {
          animationSpeed = 4;
          backgroundOpacity = 1;
          colorizeIcons = false;
          deadOpacity = 0.6;
          displayMode = "auto_hide";
          dockType = "floating";
          enabled = false;
          floatingRatio = 1;
          inactiveIndicators = false;
          monitors = [ ];
          onlySameOutput = true;
          pinnedApps = [ ];
          pinnedStatic = false;
          position = "bottom";
          showFrameIndicator = true;
          sitOnFrame = false;
          size = 1;
        };
        general = {
          allowPanelsOnScreenWithoutBar = true;
          allowPasswordWithFprintd = false;
          animationDisabled = false;
          animationSpeed = 4;
          autoStartAuth = false;
          avatarImage = "";
          boxRadiusRatio = 1;
          clockFormat = "hh\\nmm";
          clockStyle = "custom";
          compactLockScreen = false;
          dimmerOpacity = 0.2;
          enableLockScreenCountdown = true;
          enableShadows = true;
          forceBlackScreenCorners = true;
          iRadiusRatio = 1;
          keybinds = {
            keyDown = [
              "Down"
            ];
            keyEnter = [
              "Return"
            ];
            keyEscape = [
              "Esc"
            ];
            keyLeft = [
              "Left"
            ];
            keyRemove = [
              "Del"
            ];
            keyRight = [
              "Right"
            ];
            keyUp = [
              "Up"
            ];
          };
          language = "";
          lockOnSuspend = true;
          lockScreenAnimations = false;
          lockScreenBlur = 0;
          lockScreenCountdownDuration = 10000;
          lockScreenMonitors = [ ];
          lockScreenTint = 0;
          radiusRatio = 1;
          reverseScroll = false;
          scaleRatio = 1;
          screenRadiusRatio = 1;
          shadowDirection = "bottom_right";
          shadowOffsetX = 2;
          shadowOffsetY = 3;
          showChangelogOnStartup = true;
          showHibernateOnLockScreen = false;
          showScreenCorners = false;
          showSessionButtonsOnLockScreen = true;
          telemetryEnabled = false;
        };
        hooks = {
          darkModeChange = "";
          enabled = false;
          performanceModeDisabled = "";
          performanceModeEnabled = "";
          screenLock = "";
          screenUnlock = "";
          session = "";
          startup = "";
          wallpaperChange = "";
        };
        location = {
          analogClockInCalendar = false;
          firstDayOfWeek = 1;
          hideWeatherCityName = false;
          hideWeatherTimezone = false;
          autoLocate = false;
          name = "Netherlands";
          showCalendarEvents = true;
          showCalendarWeather = true;
          showWeekNumberInCalendar = true;
          use12hourFormat = false;
          useFahrenheit = false;
          weatherEnabled = false;
          weatherShowEffects = true;
        };
        network = {
          airplaneModeEnabled = false;
          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = false;
          bluetoothRssiPollIntervalMs = 60000;
          bluetoothRssiPollingEnabled = false;
          disableDiscoverability = false;
          wifiDetailsViewMode = "grid";
          wifiEnabled = true;
        };
        nightLight = {
          autoSchedule = true;
          dayTemp = "6500";
          enabled = false;
          forced = false;
          manualSunrise = "06:30";
          manualSunset = "18:30";
          nightTemp = "4000";
        };
        notifications = {
          backgroundOpacity = 1;
          clearDismissed = true;
          criticalUrgencyDuration = 15;
          density = "default";
          enableBatteryToast = true;
          enableKeyboardLayoutToast = true;
          enableMarkdown = true;
          enableMediaToast = false;
          enabled = true;
          location = "bottom_right";
          lowUrgencyDuration = 3;
          monitors = [ ];
          normalUrgencyDuration = 8;
          overlayLayer = false;
          respectExpireTimeout = true;
          saveToHistory = {
            critical = true;
            low = true;
            normal = true;
          };
          sounds = {
            criticalSoundFile = "";
            enabled = false;
            excludedApps = "discord,firefox,chrome,chromium,edge";
            lowSoundFile = "";
            normalSoundFile = "";
            separateSounds = false;
            volume = 0.5;
          };
        };
        osd = {
          autoHideMs = 2000;
          backgroundOpacity = 1;
          enabled = true;
          enabledTypes = [
            0
            1
            2
          ];
          location = "top_right";
          monitors = [ ];
          overlayLayer = true;
        };
        plugins = {
          autoUpdate = false;
        };
        sessionMenu = {
          countdownDuration = 10000;
          enableCountdown = false;
          largeButtonsLayout = "grid";
          largeButtonsStyle = true;
          position = "center";
          powerOptions = [
            {
              action = "suspend";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "1";
            }
            {
              action = "reboot";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "2";
            }
            {
              action = "shutdown";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "3";
            }
            {
              action = "lock";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "4";
            }
            {
              action = "logout";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "5";
            }
            {
              action = "rebootToUefi";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "6";
            }
            {
              action = "hibernate";
              command = "";
              countdownEnabled = true;
              enabled = false;
              keybind = "";
            }
          ];
          showHeader = true;
          showKeybinds = true;
        };
        settingsVersion = 53;
        systemMonitor = {
          batteryCriticalThreshold = 5;
          batteryWarningThreshold = 15;
          cpuCriticalThreshold = 90;
          cpuWarningThreshold = 80;
          criticalColor = "#f7768e";
          diskAvailCriticalThreshold = 10;
          diskAvailWarningThreshold = 20;
          diskCriticalThreshold = 90;
          diskWarningThreshold = 80;
          enableDgpuMonitoring = false;
          externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
          gpuCriticalThreshold = 90;
          gpuWarningThreshold = 80;
          memCriticalThreshold = 90;
          memWarningThreshold = 80;
          swapCriticalThreshold = 90;
          swapWarningThreshold = 80;
          tempCriticalThreshold = 90;
          tempWarningThreshold = 80;
          useCustomColors = false;
          warningColor = "#9ece6a";
        };
        templates = {
          activeTemplates = [ ];
          enableUserTheming = false;
        };
        ui = {
          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = false;
          boxBorderEnabled = false;
          fontDefault = "Noto Sans";
          fontDefaultScale = 1;
          fontFixed = "monospace";
          fontFixedScale = 1;
          networkPanelView = "wifi";
          panelBackgroundOpacity = 1.00;
          panelsAttachedToBar = true;
          settingsPanelMode = "window";
          tooltipsEnabled = true;
          wifiDetailsViewMode = "grid";
        };
        wallpaper = {
          automationEnabled = false;
          directory = "/home/levi/Pictures/Wallpapers";
          enableMultiMonitorDirectories = false;
          enabled = false;
          favorites = [ ];
          fillColor = "#000000";
          fillMode = "crop";
          hideWallpaperFilenames = false;
          monitorDirectories = [ ];
          overviewBlur = 0.4;
          overviewEnabled = false;
          overviewTint = 0.6;
          panelPosition = "follow_bar";
          randomIntervalSec = 300;
          setWallpaperOnAllMonitors = true;
          showHiddenFiles = false;
          skipStartupTransition = false;
          solidColor = "#1a1a2e";
          sortOrder = "name";
          transitionDuration = 1500;
          transitionEdgeSmoothness = 0.05;
          transitionType = "random";
          useSolidColor = false;
          useWallhaven = false;
          viewMode = "single";
          wallhavenApiKey = "";
          wallhavenCategories = "111";
          wallhavenOrder = "desc";
          wallhavenPurity = "100";
          wallhavenQuery = "";
          wallhavenRatios = "";
          wallhavenResolutionHeight = "";
          wallhavenResolutionMode = "atleast";
          wallhavenResolutionWidth = "";
          wallhavenSorting = "relevance";
          wallpaperChangeMode = "random";
        };
      };
    };
  };
}

