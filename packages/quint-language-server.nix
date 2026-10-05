{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage {
  pname = "quint-language-server";
  version = "0.19.0";

  # The server is released from the Quint monorepo with its own version.
  src = fetchFromGitHub {
    owner = "quint-co";
    repo = "quint";
    tag = "v0.32.0";
    hash = "sha256-GTbphBmALx/gDc/iV/wtE1ovpK43VtCQoneN5AqUmvg=";
  };
  sourceRoot = "source/vscode/quint-vscode/server";
  npmDepsHash = "sha256-BT5KN9E5aRUIJQR0zGlT00tDmRpS2oFF/yOdQOPIGgQ=";
  npmBuildScript = "compile";

  # Upstream imports this shared protocol type from the VS Code client,
  # which is only installed in the parent extension, not the server.
  postPatch = ''
    substituteInPlace src/complete.ts \
      --replace-fail "from 'vscode-languageclient'" "from 'vscode-languageserver'"
  '';

  # npm's prepare hook normally does this after compiling the server.
  postBuild = ''
    chmod +x out/src/server.js
  '';

  meta = {
    description = "Language server for the Quint specification language";
    homepage = "https://quint-lang.org";
    license = lib.licenses.asl20;
    mainProgram = "quint-language-server";
  };
}
