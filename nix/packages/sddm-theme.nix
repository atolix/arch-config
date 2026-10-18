{ stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "arch-config-sddm-theme";
  version = "1.0.0";

  src = ../../sddm/mysddm;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/sddm/themes/mysddm"
    cp -r . "$out/share/sddm/themes/mysddm"

    runHook postInstall
  '';
}
