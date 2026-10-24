{config, ...}: {
  nixpkgs.overlays = [
    (_final: prev: {
      kernelPackagesExtensions =
        prev.kernelPackagesExtensions
        ++ [
          (kernelFinal: kernelPrev: {
            v4l2loopback = kernelPrev.v4l2loopback.overrideAttrs (_old: let
              kernel = kernelFinal.kernel;
            in {
              __structuredAttrs = true;
              strictDeps = true;
              enableParallelBuilding = true;

              nativeBuildInputs = kernel.moduleBuildDependencies;
              makeFlags = [];

              installFlags = [
                "DEPMOD=true"
                "INSTALL_MOD_PATH=${builtins.placeholder "out"}"
              ];

              postBuild = "";
              postInstall = "";

              buildPhase = ''
                runHook preBuild
                make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) "''${makeFlags[@]}"
                make utils
                runHook postBuild
              '';

              installPhase = ''
                runHook preInstall
                make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules_install \
                  "''${makeFlags[@]}" "''${installFlags[@]}"
                make install-utils PREFIX=$bin
                runHook postInstall
              '';
            });
          })
        ];
    })
  ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.v4l2loopback
  ];
}
