{
  description = "Hugo Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

  flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" ] (system:
  let
    pkgs = import nixpkgs { inherit system; };
    lib  = pkgs.lib;
  in {
    devShells.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [ 
        git 
        hugo
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
      ];
      shellHook = ''
        export SHELL=${pkgs.zsh}/bin/bash
        export PS1="(devShell) \[\033[38;2;166;227;161m\]\u\[\033[0m\]:\[\033[38;2;249;226;175m\]\w\[\033[0m\]\[\033[38;2;205;214;244m\]\$ \[\033[0m\]"
      '';
    };
  });
}
