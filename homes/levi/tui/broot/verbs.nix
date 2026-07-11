# Custom commands.

# NOTES:
# - Verb invocation pattern syntax:
#   Invocation patterns are parsed as (Rust) regex, and you can use capture groups to destructure
#   a verb's passed arguments: in the command to be executed, broot expands `{arg}` to the
#   value captured by the group named `arg`. If you use `{arg}` in the invocation pattern's definition,
#   it appears to be an "alias" that expands to capture group `(?<arg>.+)`
#   Also, note that since these are first parsed a json or toml parser, you need to escape
#   any backslashes to then escape any special regex characters, e.g. `\\.` to escape `.`.
# - Duplicates/overloading verbs:
#   It appears duplicate invocations/keymaps are possible as long as their
#   application conditons are mutually exclusive, otherwise it picks the first
#   defined one that is applicable. As such, there's also no overloading.
# - Verb-arg syntax in `external`:
#   There is poorly documented syntax for expanding verb args (eg. `{arg}`) in
#   an `external` command that is quite convenient:
#     * {arg:path-from-parent}: Interprets arg as a path, and if relative
#       prefixes with parent of current selection.
#     * {arg:path-from-directory}: Same as above but if a directly is currently
#       selected use that instead of its parent
#     * {file:space-separated} and {file:comma-separated}: when invoking a verb
#       on the staging area, merge all selections into this one argument and invoke
#       only once instead of separelty for each file.

let
  verb_defaults = {
    leave_broot = false; # Be careful that if we add from_shell this also need to be true
    set_working_dir = true; # working_dir still overrides this when we need it
  };
  set_defaults = map (verb: verb_defaults // verb);
in
set_defaults [

  # NAVIGATION
  { key = "shift-j"; internal = ":next_dir"; }
  { key = "shift-k"; internal = ":previous_dir"; }
  { key = "r"; internal = ":select_first";  }
  { key = "shift-r"; internal = ":select_last";  }
  { key = "."; internal = ":toggle_hidden"; }
  { key = ">"; internal = ":toggle_ignore"; }
  { key = "f"; internal = ":toggle_files"; }
  { key = "shift-f"; internal = ":toggle_tree"; }
  { key = "i"; internal = ":toggle_dates"; }
  { key = "shift-i"; internal = ":toggle_sizes"; }

  { key = "q"; internal = ":quit"; }
  {
    # Override :cd default to work even if no directory is selected (uses parent instead)
    invocation = "cd"; keys = [ "shift-q" "ctrl-q" ];
    external = "cd {directory}"; from_shell = true; leave_broot = true;
  }
  {
    invocation = "goto {path}"; shortcut = "gt"; key = "g";
    cmd = ":focus {path:path-from-directory};:show {path:path-from-directory}";
  }
  {
    invocation = "goto_at {dir} {subpath}"; shortcut = "gta"; key = "shift-g";
    cmd = ":focus {dir:path-from-directory};:show {subpath}";
  }

  # FILE MANIPULATION
  { key = "s"; cmd =":toggle_stage;:line_down"; }
  { key = "shift-s"; cmd =":toggle_stage;:line_up"; }
  {
    # Touch file/dir
    invocation = "touch {path}";
    external = "touch {path}";
    switch_terminal = false;
  }
  {
    # Create file and any parent directories above it, and move focus to it
    invocation = "create (?<dir>.*/)?(?<name>[^/]+)"; shortcut = "cr"; key = "a";
    cmd = ":mkdir {dir}/.;:focus {dir};:touch {name};:show {name}"; auto_exec = false;
  }
  {
    # Create file at {dir}/{subpath}, set {dir} as displayed root and select {subpath}
    invocation = "create_at {dir} (?<subpath>(?<subdir>.*/)?(?<name>[^/]+))"; shortcut = "cra"; key = "shift-a";
    cmd = ":focus {dir};:mkdir {subdir};:touch {subpath};:show {subpath}"; auto_exec = false;
  }
  {
    # Copy and move (cut) shortcuts, with special behaviours for staging area
    invocation = "copy {to_path}"; shortcut = "cp"; keys = [ "y" "ctrl-y" ]; panels = [ "tree" "fs" "preview" "help" ];
    external = "cp -r {file} {to_path:path-from-parent}"; auto_exec = false;
  }
  {
    invocation = "copy"; shortcut = "cp"; keys = [ "y" "ctrl-y" ]; panels = [ "stage" ];
    external = "cp -r {file:space-separated} {other-panel-directory}"; auto_exec = false;
  }
  {
    invocation = "move {to_path}"; shortcut = "mv"; keys = [ "x" "ctrl-x" ]; panels = [ "tree" "fs" "preview" "help" ];
    external = "mv {file} {to_path:path-from-parent}"; auto_exec = false;
  }
  {
    invocation = "move"; shortcut = "mv"; kes = [ "x" "ctrl-x" ]; panels = [ "stage" ];
    external = "mv {file:space-separated} {other-panel-directory}"; auto_exec = false;
  }
  {
    # Trash and rm -rf shortcuts, which prompt for confirmation.
    invocation = "trash"; keys = [ "d" "ctrl-t" ];
    internal = ":trash"; auto_exec = false;
  }
  {
    invocation = "rm"; keys = [ "shift-d" "alt-t" ];
    external = "rm -rf {file}"; auto_exec = false;
  }
  {
    # Zip selected file(s) into a new archive named <name>.zip
    # Mainly useful in combination with staging area
    invocation = "zip {name}";
    external = [
      "zip"
      "-r"
      "{name:path-from-directory}.zip"
      "{file:space-separated}"
    ];
    working_dir = "{root}";
  }

  # OPENING/EDITING
  {
    # Open text file in terminal $EDITOR (takes precedence over default open action)
    invocation = "edit"; shortcut = "e"; keys = [ "e" "enter" ]; apply_to = "text_file";
    external = "$EDITOR {file:space-separated}";
  }
  {
    # Open directory in terminal $EDITOR
    invocation = "edit"; shortcut = "e"; keys = [ "e" ]; apply_to = "directory";
    external = "$EDITOR {directory:space-separated}";
  }
  {
    # Internal verbs :open_stay and :open_leave use :edit instead for text files
    # This is cuz it otherwise xdg-opens a TUI editor in a seperate process without a controlling
    # terminal, thus "leaking" the process into the background even after closing broot
    invocation = "open_stay"; shortcut = "os"; key = "enter"; apply_to = "text_file";
    cmd = ":edit";
  }
  {
    invocation = "open_leave"; shortcut = "ol"; key = "alt-enter"; apply_to = "text_file";
    cmd = ":edit";
    leave_broot = true;
  }
  {
    # Alias open_stay with open and add a keybind for it.
    invocation = "open"; shortcut = "o"; keys = [ "o" "ctrl-o" ];
    cmd = ":open_stay";
  }
  {
    # Add alternate binds for open_leave
    keys = [ "shift-o" "alt-o" ];
    cmd = ":open_leave";
    leave_broot = true;
  }

  # SHELL COMMAND
  {
    invocation = "shell {cmd}"; shortcut = "sh";
    external = [ "sh" "-ce" "{cmd}" ];
  }

  # ZOXIDE+BASH INTEGRATION (requires server mode to be on with --listen flag)
  {
    invocation = "zoxide {dir}"; shortcut = "z"; keys = [ "z" "ctrl-z" ];
    external = [ "sh" "-ce" "broot --send {server-name} -c \":focus $(zoxide query {dir} --exclude {root})\"" ];
    auto_exec = false; switch_terminal = false;
  }
]
