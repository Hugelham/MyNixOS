{ self, inputs, ... }: {
  
  flake.nixosModules.home-pcHardware = { config, lib, pkgs, modulesPath, ... }:	{
	  imports = [ ];

	  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
	  boot.initrd.kernelModules = [ ];
	  boot.kernelModules = [ ];
	  boot.extraModulePackages = [ ];

	  fileSystems."/" =
	    { device = "/dev/disk/by-uuid/f7ee10de-a67f-47dc-89b2-599a427f82ba";
	      fsType = "ext4";
	    };

	  fileSystems."/boot" =
	    { device = "/dev/disk/by-uuid/63CA-628F";
	      fsType = "vfat";
	      options = [ "fmask=0077" "dmask=0077" ];
	    };

	  swapDevices = [ ];

	  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	  virtualisation.virtualbox.guest.enable = true;
	};
}
