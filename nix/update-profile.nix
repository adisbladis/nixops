{ machines }:

let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

in pkgs.runCommand "nixops-machines" {}
  ''
    mkdir -p $out
    ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
      ln -s "${v}" $out/"${n}"
    '') machines)}
  ''
