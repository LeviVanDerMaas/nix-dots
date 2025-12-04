usage() {
    cat <<EOF
Get the Nix store paths of derivation outputs.

Each argument must be a Nix expression that evaluates to a derivation.
Nixpkgs is automatically added to scope (from NIX_PATH); override with -l or -I.
By default, the store path of the main output of each derivation is returned;
note that paths are not guaranteed to exist, but you can ensure this with -b.


NOTE: To use this you must enable the experimental "nix" command.

Flags:
Later flags override earlier ones where applicable.
-a, --all-outputs  List paths of all derivation outputs, rather than just main.
-d, --derivations  List paths of derivatons themselves, rather than their outputs.
-b, --build        Build each listed path, ensuring it exists. Overrides -r.
-r, --read-only    Do not instantiate (nor build) derivations. Overrides -b.
-I, --include      Add entry to search path. Can be supplied multiple times.
-l, --load         Nix expression added to scope. Default: \`import <nixpkgs> {}\`
-h, --help         Display this help message, do not do anything else.
--                 All arguments after this are treated as derivation expressions.
EOF
}

parsed_args=$(getopt --name nix-sp --options 'adbrI:l:h' --longoptions 'all-outputs,derivations,build,read-only,include:,load:,help' -- "$@")
eval "set -- $parsed_args"

# Flag variables and their defaults
paths_kind="mainOutPaths" # --derivations; --all-outputs
build= # --build
read_only= # --read_only
includes= # --include
load="import <nixpkgs> {}" # --load

while true; do
    case "$1" in
        -a | --all-outputs)
            paths_kind="allOutPaths"
            shift;;
        -d | --derivations)
            paths_kind="drvPaths"
            shift;;
        -b | --build)
            build=1
            read_only=
            shift;;
        -r | --read-only)
            read_only=1
            build=
            shift;;
        -I | --include)
            includes="$includes -I $2"
            shift 2;;
        -l | --load)
            load="$2"
            shift 2;;
        -h | --help)
            usage
            exit 0;;
        --)
            shift
            # If no argument given, exit with usage
            if [[ ! -v 1 ]]; then
                usage >&2
                exit 1
            fi;
            break;;
        *)
            echo "ERROR - Invalid flag: $1. Type \`nix-sp -h\` for usage help." >&2
            exit 1;;
    esac
done

# Remaining positional parameters should be wrapped each into parentheses to
# ensure they don't get tangled up with other expressions when placed into an
# expression. Note that this relies on bash's builtin printf repeating the
# format as necessary, which isn't the case for all printf versions.
expressions=${1:+$(printf "(%s) " "$@")}

paths=$(nix eval --impure --raw --quiet --quiet --quiet --quiet --quiet \
    ${read_only:+--read-only} $includes --expr \
    "with $load; let
        drvs = [ $expressions ];
        drvPaths = builtins.map (d: d.drvPath) drvs;
        mainOutPaths = builtins.map (d: d.outPath) drvs;
        allOutPaths = builtins.concatMap (d: builtins.map (d': d'.outPath) d.all) drvs;
    in
        builtins.concatStringsSep \"\n\" $paths_kind + \"\n\""
)

if [[ $build -eq 1 ]]; then
    # Yes, this takes the output paths rather than the derivation paths (barring
    # the -d flag being set). nix build actually expects these paths instead of
    # .drv paths, otherwise it "builds" just the drv files instead; also yes,
    # nix can compute to what .drv file an output path corresponds even if said
    # path doesn't yet exist (try it yourself with nix-store --valid-derivers).
    # Documentation on this is poor and there are some unanswered github issues
    # on why nix build does this... But it does seem intentionally so
    nix build --no-link $paths
fi

echo $paths







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
