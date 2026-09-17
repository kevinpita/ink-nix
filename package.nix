{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  versionCheckHook,
}:
let
  release = builtins.fromJSON (builtins.readFile ./sources.json);
  source =
    release.sources.${stdenv.hostPlatform.system}
      or (throw "ink is not supported on ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "ink";
  inherit (release) version;

  src = fetchurl {
    url = "https://github.com/borghei/ink/releases/download/v${release.version}/${source.asset}";
    inherit (source) hash;
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/ink"
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  meta = {
    description = "Terminal Markdown reader with syntax highlighting and inline images";
    homepage = "https://github.com/borghei/ink";
    changelog = "https://github.com/borghei/ink/releases/tag/v${release.version}";
    license = lib.licenses.mit;
    mainProgram = "ink";
    platforms = builtins.attrNames release.sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
