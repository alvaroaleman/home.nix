{
  buildGo127Module,
  fetchFromGitHub,
  lib,
}:

buildGo127Module (finalAttrs: {
  pname = "temporal-cloud";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "temporalio";
    repo = "cloud-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UiH+2mbtYATf0WDdurAQRoVgUIKTNUOqOhkfwDSTHgU=";
  };

  vendorHash = "sha256-qxXvU1P2RY5wem/pvtY10V84wlU9RmxlO0KFuSwjvWU=";
  subPackages = [ "cmd/temporal-cloud" ];
  ldflags = [
    "-s"
    "-w"
    "-X github.com/temporalio/cloud-cli/temporalcloudcli.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Temporal CLI extension for managing Temporal Cloud resources";
    homepage = "https://github.com/temporalio/cloud-cli";
    license = lib.licenses.mit;
    mainProgram = "temporal-cloud";
  };
})
