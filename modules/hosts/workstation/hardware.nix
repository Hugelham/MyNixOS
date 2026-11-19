{ self, inputs, ... }: {
  
  flake.nixosModules.workstationHardware = { config, lib, pkgs, modulesPath, ... }: {
		imports =
			[ (modulesPath + "/installer/scan/not-detected.nix")
			];

		hardware.graphics = {
			enable = true;
			enable32Bit = true;
		};

		boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
		boot.initrd.kernelModules = [ "amdgpu" ];
		boot.kernelModules = [ "kvm-amd" ];
		boot.extraModulePackages = [ ];
		boot.kernelParams = [ 
			"mem_sleep_default=deep" 
			"amd_iommu=on" 
			"amdgpu.runpm=1"
		];
		services.xserver.videoDrivers = ["amdgpu"];


		services.power-profiles-daemon.enable = true;

		fileSystems."/" =
			{ device = "/dev/disk/by-uuid/6980da5d-2f9a-4107-9798-3994f3ef8183";
				fsType = "ext4";
			};

		fileSystems."/boot" =
			{ device = "/dev/disk/by-uuid/1395-C559";
				fsType = "vfat";
				options = [ "fmask=0077" "dmask=0077" ];
			};

		swapDevices = [{ 
			device = "/swapfile";
			size = 120*1024;
		}];

		nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
		hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
	};
}
