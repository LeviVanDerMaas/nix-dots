{
  # dolphin-out-of-plasma = final: prev: {
  #   dolphin = prev.dolphin.overrideAttrs (prevAttrs: {
  #   });
  # };
  hello-test = final: prev: {
    hello = final.symlinkJoin {
      name = "hello";
      buildInputs = [ final.makeWrapper ];
      paths = [ prev.hello ];
      postBuild = ''
        wrapProgram $out/bin/hello \
          --add-flags "-t"
      '';
    };
  };
  cowsay-test = final: prev: {
    cowsay = final.writeShellScriptBin "cowsay" ''
      exec ${prev.cowsay}/bin/cowsay $(${final.hello}/bin/hello)
'';
  };
}
