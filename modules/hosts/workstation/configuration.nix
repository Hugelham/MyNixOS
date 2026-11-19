{ self, inputs, ... }: {

  flake.nixosModules.workstationConfiguration = { config, pkgs, lib, ... }:

	{

	imports = [
		self.nixosModules.workstationHardware
		self.nixosModules.niri	   
		self.nixosModules.serpantinum
		self.nixosModules.join_domain
		self.nixosModules.ghostty
		inputs.nix-index-database.nixosModules.default
		inputs.spicetify-nix.nixosModules.default
		
	];

	programs.nh = {
		enable = true;
		flake = "/etc/nixos/MyNixOs";
  	};

	programs.spicetify =
		let
		spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
		in
		{
		enable = true;

		enabledExtensions = with spicePkgs.extensions; [
			adblock
			hidePodcasts
			shuffle # shuffle+ (special characters are sanitized out of extension names)
		];
		enabledCustomApps = with spicePkgs.apps; [
			newReleases
			ncsVisualizer
		];
		enabledSnippets = with spicePkgs.snippets; [
			rotatingCoverart
			pointer
		];

		theme = spicePkgs.themes.hazy;
	};

	nix.settings.experimental-features = [ "nix-command" "flakes"];
	services.flatpak.enable = true;

	environment.systemPackages = with pkgs; [
		kitty cliphist wl-clipboard grim slurp pavucontrol     
		git vscode ghostty nh ripgrep slack
		inputs.serpantinum.packages.${pkgs.stdenv.hostPlatform.system}.default
		teams-for-linux remmina zed-editor steam
	];

	programs.zsh = {
		enable = true;
		promptInit = ''
			PROMPT='%F{blue}%~%f %# '
		'';
	};
		
    services.displayManager.defaultSession = lib.mkForce "niri";	  
	  boot.loader.systemd-boot.enable = true;
	  boot.loader.efi.canTouchEfiVariables = true;

	  boot.kernelPackages = pkgs.linuxPackages_latest;

	  networking.hostName = "Kyle"; # Define your hostname.
	  networking.networkmanager.enable = true;
      hardware.bluetooth.enable = true;
	  time.timeZone = "America/Denver";



	
	  i18n.defaultLocale = "en_US.UTF-8";

	  i18n.extraLocaleSettings = {
	    LC_ADDRESS = "en_US.UTF-8";
	    LC_IDENTIFICATION = "en_US.UTF-8";
	    LC_MEASUREMENT = "en_US.UTF-8";
	    LC_MONETARY = "en_US.UTF-8";
	    LC_NAME = "en_US.UTF-8";
	    LC_NUMERIC = "en_US.UTF-8";
	    LC_PAPER = "en_US.UTF-8";
	    LC_TELEPHONE = "en_US.UTF-8";
	    LC_TIME = "en_US.UTF-8";
	  };

	  programs.nix-index-database.comma.enable = true;

	  services.xserver.enable = true;

	  services.displayManager.sddm.enable = true;
	  services.desktopManager.plasma6.enable = true;

	  services.xserver.xkb = {
	    layout = "us";
	    variant = "";
	  };

	  services.printing.enable = true;

	  services.pulseaudio.enable = false;
	  security.rtkit.enable = true;
	  services.pipewire = {
	    enable = true;
	    alsa.enable = true;
	    alsa.support32Bit = true;
	    pulse.enable = true;
	  };

	  # Define a user account. Don't forget to set a password with ‘passwd’.
	  users.users."daniel" = {
	    isNormalUser = true;
	    description = "daniel";
	    extraGroups = [ "networkmanager" "wheel" ];
	    packages = with pkgs; [
	      kdePackages.kate
	    ];
	  };

	  programs.firefox.enable = true;

	  nixpkgs.config.allowUnfree = true;

	  system.stateVersion = "26.05"; # Did you read the comment?

	};

}
