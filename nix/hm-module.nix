# Home Manager module for OpenRec
# Usage in flake-based Home Manager config:
#
#   inputs.openrec.url = "github:EtienneLescot/openrec";
#
#   { inputs, ... }: {
#     imports = [ inputs.openrec.homeManagerModules.default ];
#     programs.openrec.enable = true;
#   }
self:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.openrec;
in
{
  options.programs.openrec = {
    enable = lib.mkEnableOption "OpenRec screen recorder";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.openrec;
      defaultText = lib.literalExpression "inputs.openrec.packages.\${pkgs.stdenv.hostPlatform.system}.openrec";
      description = "The OpenRec package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
