{ config, lib, uuid, name, ... }:

let
  inherit (lib) mkOption types;

in {

  options = {

    publicKey = mkOption {
      default = "";
      type = types.str;
      description = "The generated public SSH key.";
    };

    privateKey = mkOption {
      default = "";
      type = types.str;
      description = "The generated private key.";
    };

  };

}
