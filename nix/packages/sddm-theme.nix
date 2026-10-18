{
  lib,
  stdenvNoCC,
  theme ? { },
}:

let
  themeDefaults = import ../sddm-theme.nix;
  resolvedTheme = themeDefaults // theme;
in

stdenvNoCC.mkDerivation {
  pname = "linux-config-sddm-theme";
  version = "1.0.0";

  src = ../../sddm/mysddm;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/sddm/themes/mysddm"
    cp -r . "$out/share/sddm/themes/mysddm"
    substituteInPlace "$out/share/sddm/themes/mysddm/Main.qml" \
      --replace-fail '#141414' ${lib.escapeShellArg resolvedTheme.background} \
      --replace-fail '#b8141414' ${lib.escapeShellArg resolvedTheme.overlay} \
      --replace-fail '#e61f222b' ${lib.escapeShellArg resolvedTheme.field} \
      --replace-fail '#e62c3040' ${lib.escapeShellArg resolvedTheme.fieldFocus} \
      --replace-fail '#eaeaea' ${lib.escapeShellArg resolvedTheme.text} \
      --replace-fail '#f38ba8' ${lib.escapeShellArg resolvedTheme.error} \
      --replace-fail '#a5b4fc' ${lib.escapeShellArg resolvedTheme.accent} \
      --replace-fail '#414552' ${lib.escapeShellArg resolvedTheme.border} \
      --replace-fail '#777d91' ${lib.escapeShellArg resolvedTheme.placeholder} \
      --replace-fail '#66ffffff' ${lib.escapeShellArg resolvedTheme.selection}

    runHook postInstall
  '';
}
