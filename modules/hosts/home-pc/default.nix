{ self, inputs, ...}: {
  flake.nixosConfigurations.home-pc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.home-pcConfiguration
   ];
 };

}
