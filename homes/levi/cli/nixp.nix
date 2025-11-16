# TODO: Work in progress

read_only=
includes=
load=
expression=

set -- $(getopt --name nix-path --options 'adrI:l::' --longoptions 'all-outputs,derivations,read-only,include:,load::')

# Take all derivation expressions and wrap them in brackets, so that can put them into a list.
# Note that this relies on bash's builtin printf repeating the format as necessary, 
# which isn't the case for all printf versions.
expressions=$(printf '(%s) ' "$@")

nix eval --impure --raw --quiet --quiet --quiet --quiet --quiet \
    ${read_only:+--read-only} $includes --expr \
    "with ${load:-"import <nixpkgs> {}"}; let \
        drvs = [ $expressions ]; \
        drvPaths = builtins.map (d: d.drvPath) drvs; \
        mainOutPaths = builtins.map (d: d.outPath) drvs; \
        allOutPaths = builtins.concatMap (d: builtins.map (d': d'.outPath) d.all) drvs; \
    in \
        builtins.concatStringsSep \"\n\" allOutPaths + \"\n\""

# Documentation on builtins.derivation return value is very poor, but
# after doing some digging through nixcpp source code and Edolstra's thesis:
#
# In the original thesis, it is supposed to return only its original input
# with three attributes added:
# - type: always set to the value "derivation"
# - drvPath: store path of the derivation
# - outPath: store path of the (main) output
# As an aside, it is interesting to note that most nix tools use  { type =
# "derivation"; } as an indicator that an attrset is a derivation, even if
# would be missing other attributes. For example, nix eval will pretty print
# such an attrset as "«derivation»".
#
# In nixcpp, however, it adds (NOT replaces) more attributes:
# - drvAttrs: the original attrset passed to builtins.derivation (not defaults)
# - outputs: Added ONLY IF this exists on drvAttrs, with the same value
# - "x": for each x in outputs (or "out"), add x with variation of this attrset
# - outputName: string matching one of the above "x"
# - all: list of all values of all of the above "x"
# Each "x" contains this attrset, but with outputName set to "x" and with outputPath
# set to store path of the output corresponding to "x". Note that the other attributes
# remain as specified above, which means that each such attrset contains itself in
# both the all attribute and the corresponding "x" attribute (infinitely recursive).
#
# These additional attributes all seem to be towards supporting multiple outputs.
# The original thesis did not formally support multiple outputs, although it did
# suggest a syntax for future implementation of this (but no implementation details).
# To that end it also seems the undocumented builtin.derivationStrict was implemented,
# which is what builtins.derivation wraps as a pure nix expression. Internal
# doc in source code claims that builtin.derivationStrict's should return the
# original input attrset plus type, drvPath and outPath; but it actually returns an attrset
# containing ONLY drvPath and an attribute named after each output containing the store path
# of that output.
