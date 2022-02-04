{
  description = "Standard C++ Project Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
        let
          pkgs = import nixpkgs { inherit system; };
          llvm = pkgs.llvmPackages_latest;
          lib = nixpkgs.lib;

        in
          {
            devShell = pkgs.mkShell {
              nativeBuildInputs = [
                # builder
                # p.gnumake
                # p.bear
                pkgs.cmake
                pkgs.cmakeCurses
                # debugger
                llvm.lldb

                # XXX: the order of include matters
                pkgs.clang-tools
                llvm.clang # clangd

                pkgs.gtest

                pkgs.ncurses
              ];

              buildInputs = [
                # stdlib for cpp
                llvm.libcxx
              ];

              # CXXFLAGS = "-std=c++17";
              CPATH = builtins.concatStringsSep ":" [
                (lib.makeSearchPathOutput "dev" "include" [ llvm.libcxx ])
                (lib.makeSearchPath "resource-root/include" [ llvm.clang ])
              ];

              shellHook = let
                icon = "f121";
                triangle = "E0B0";
                black = "\\e[0;30m";
                red = "\\e[0;31m";
                green = "\\e[0;32m";
                yellow = "\\e[0;33m";
                blue = "\\e[0;34m";
                magenta = "\\e[0;35m";
                cyan = "\\e[0;36m";
                white = "\\e[0;37m";
                bold = "\\e[1m";
                uline = "\\e[4m";
                reset = "\\e[0m";
              in ''
                export DEBUG_FLAGS="\
                -g3 \
                -pthread \
                -gdwarf-4 \
                -fPIC \
                -Wno-deprecated \
                -pipe \
                -fno-elide-type \
                -fdiagnostics-show-template-tree \
                -Wall \
                -Wextra \
                -Werror \
                -Wreturn-type \
                -Wpedantic \
                -Wvla \
                -Wextra-semi \
                -Wnull-dereference \
                -Wswitch-enum \
                -Wsuggest-override \
                -O \
                -MP \
                -Wno-gnu-include-next \
                -Wno-unused-variable \
                -Wno-unused-parameter"

                # Usage: mycmake -B . -S ../
                alias mycmake='cmake \
                -DCMAKE_C_COMPILER=clang \
                -DCMAKE_CXX_COMPILER=clang++ \
                -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
                -DCMAKE_CXX_FLAGS_ALL_WARNINGS:STRING="$DEBUG_FLAGS" \
                -DCMAKE_BUILD_TYPE=ALL_WARNINGS'

                # Usage: myclang-tidy -p build main.cpp
                alias myclang-tidy='clang-tidy \
                --checks="-*,\
                boost-*,\
                bugprone-*,\
                clang-analyzer-*,\
                concurrency-*,\
                cppcoreguidelines-*,\
                misc-*,\
                modernize-*,\
                performance-*,\
                portability-*,\
                readability-*" \
                -header-filter=.*'
                #alias myclang-tidy='clang-tidy --checks="-*, boost-*, bugprone-*, clang-analyzer-*, concurrency-*, cppcoreguidelines-*, misc-*, modernize-*, performance-*, portability-*, readability-*" -header-filter=.*'

                # Usage: mycppcheck main.cpp
                alias mycppcheck="cppcheck --enable=all --std=c++20"

                #export PS1="$(echo -e '\u${icon}') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} \\$ \[$(tput sgr0)\]"
                #export PS1="\n\[\033[1;43;30m\] $(echo -e '\u${icon}') \w \[\033[0m\]\[\033[1;33m\]$(echo -e '\u${triangle}')\[\033[0m\] \[$(tput sgr0)\]"
                export PS1="╭╴${red}$(echo -e '\u${icon} DEV') ${reset}${yellow}${bold}\W${reset} ${green}${uline}\$(git rev-parse --abbrev-ref HEAD 2>/dev/null)${reset}
╰─λ "
              '';
            };
          }
    );
}

