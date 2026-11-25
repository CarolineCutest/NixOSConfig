{
  nixpkgs.overlays = [
    (_: prev: {
      kernelPackagesExtensions = prev.kernelPackagesExtensions ++ [
        (kernelFinal: kernelPrev: {
          virtualbox = kernelPrev.virtualbox.overrideAttrs (old: {
            makeFlags = kernelFinal.kernelModuleMakeFlags ++ old.makeFlags ++ [
              "VBOX_ALLOW_MODULE_SIGNING=1"
            ];
          });
        })
      ];
    })
  ];
}
