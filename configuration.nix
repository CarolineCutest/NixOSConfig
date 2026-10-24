# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./module.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel Modules
  boot.extraModulePackages = [ config.boot.kernelPackages.msi-ec ];
  boot.kernelModules = [ "msi-ec" "ec_sys"];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_BE.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "be";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "be-latin1";

  #Auto upgrade
  system.autoUpgrade.enable = true;
  # Warning "allowReboot = true" allow the upgrade to reboot the machine in order to upgrade the kernel,
  # if set to false it will stay in the current channel and only upgrade to last version in the current channel.
  system.autoUpgrade.allowReboot = true;


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.f
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Configure the NVIDIA driver
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # Use the open-source kernel module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Use the Bus IDs you found earlier
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Load the nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."caroline" = {
    isNormalUser = true;
    description = "caroline";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    packages = with pkgs; [
    #GAMING
      eden
      xrizer
      prismlauncher
      olympus
    #CREATION
      obsidian
      orca-slicer
      kicad
      arduino-ide
      vscodium
    #WINE
      lutris
      protonup-qt
      wine64
    #NETWORK
      nmap
      angryipscanner
    #TOOLS
      tor-browser
      vesktop
      keepassxc
      filen-desktop
      via
      (llama-cpp.override { cudaSupport = true; })
    ];
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
  };

  #Install WiVRN
  services.wivrn = {
    enable = true;
    openFirewall = true;
    # Run WiVRn as a systemd service on startup
    autoStart = true;
    # If you're running this with an nVidia GPU and want to use GPU Encoding (and don't otherwise have CUDA enabled system wide), you need to override the cudaSupport variable.
    package = (pkgs.wivrn.override { cudaSupport = true; });
    # You should use the default configuration (which is no configuration), as that works the best out of the box.
    # However, if you need to configure something see https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md for configuration options and https://mynixos.com/nixpkgs/option/services.wivrn.config.json for an example configuration.
};

  #Install steam
  programs.steam = {
     enable = true;
     remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
     dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
     package = pkgs.steam.override {
     extraProfile = ''
      # Allows Monado/WiVRn to be used
      export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
      # Fixes timezones on VRChat
      unset TZ
    '';
    };
   };


  #Install flatpack
  services.flatpak.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "gtk";

  #Virtualbox
  virtualisation.virtualbox.host.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
   environment.systemPackages = with pkgs; [
  #TERMINAL TOOLS
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     net-tools
     traceroute
     wireguard-tools
     android-tools
     testdisk
     tlp
  #KDE PACKAGES
     kdePackages.kate
     kdePackages.isoimagewriter
     kdePackages.kdenlive
     kdePackages.partitionmanager
     kdePackages.kdeconnect-kde
  #USEFULL APPS
     thunderbird
     libreoffice
     peazip
     lshw-gui
     mcontrolcenter
     filezilla
     inkscape-with-extensions
     gimp-with-plugins
     lact
     vlc
     gpu-screen-recorder-ui
     qbittorrent
     networkmanager
     networkmanagerapplet
  #DEPENDENCIES
    jre25_minimal
    python314
    python314Packages.pip
   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?

}
