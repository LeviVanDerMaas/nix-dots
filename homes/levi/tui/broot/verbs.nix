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
  # Override :cd default to work even if no directory is selected (uses parent instead)
  {
    invocation = "cd"; key = "ctrl-q";
    external = "cd {directory}"; from_shell = true; leave_broot = true;
  }
  {
    invocation = "goto {path}"; shortcut = "gt";
    cmd = ":focus {path:path-from-directory};:show {path:path-from-directory}";
  }
  {
    invocation = "goto_at {dir} {subpath}"; shortcut = "gta";
    cmd = ":focus {dir:path-from-directory};:show {subpath}";
  }

  # FILE MANIPULATION
  # Touch file/dir
  {
    invocation = "touch {path}";
    external = "touch {path}";
    switch_terminal = false;
  }
  # Create file and any parent directories, and move focus to it
  {
    invocation = "create (?<dir>.*/)?(?<name>[^/]+)"; shortcut = "cr";
    cmd = ":mkdir {dir}/.;:focus {dir};:touch {name};:show {name}";
  }
  # Create file at {dir}/{subpath}, set {dir} as displayed root and select {subpath}
  {
    invocation = "create_at {dir} (?<subpath>(?<subdir>.*/)?(?<name>[^/]+))"; shortcut = "cra";
    cmd = ":focus {dir};:mkdir {subdir};:touch {subpath};:show {subpath}";
  }
  # Copy and move (cut) shortcuts, with special behaviours for staging area
  {
    invocation = "copy {to_path}"; shortcut = "cp"; key = "ctrl-y"; panels = [ "tree" "fs" "preview" "help" ];
    external = "cp -r {file} {to_path:path-from-parent}"; auto_exec = false;
  }
  {
    invocation = "copy"; shortcut = "cp"; key = "ctrl-y"; panels = [ "stage" ];
    external = "cp -r {file:space-separated} {other-panel-directory}"; auto_exec = false;
  }
  {
    invocation = "move {to_path}"; shortcut = "mv"; key = "ctrl-x"; panels = [ "tree" "fs" "preview" "help" ];
    external = "mv {file} {to_path:path-from-parent}"; auto_exec = false;
  }
  {
    invocation = "move"; shortcut = "mv"; key = "ctrl-x"; panels = [ "stage" ];
    external = "mv {file:space-separated} {other-panel-directory}"; auto_exec = false;
  }
  # Trash and rm -rf shortcuts, which prompt for confirmation.
  {
    invocation = "trash"; key = "ctrl-r";
    internal = ":trash"; auto_exec = false;
  }
  {
    invocation = "rm"; key = "alt-r";
    external = "rm -rf {file}"; auto_exec = false;
  }
  # Zip selected file(s) into a new archive named <name>.zip
  # Mainly useful in combination with staging area
  {
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
  # Open text file in terminal $EDITOR (takes precedence over default open action)
  {
    invocation = "edit"; shortcut = "e"; key = "enter"; apply_to = "text_file";
    external = "$EDITOR {file:space-separated}";
  }
  # Open directory in terminal $EDITOR
  {
    invocation = "edit"; shortcut = "e"; apply_to = "directory";
    external = "$EDITOR {directory:space-separated}";
  }
  # Internal verbs :open_stay and :open_leave use :edit instead for text files
  # This is cuz it otherwise xdg-opens a TUI editor in a seperate process without a controlling
  # terminal, thus "leaking" the process into the background even after closing broot
  {
    invocation = "open_stay"; shortcut = "os"; key = "enter"; apply_to = "text_file";
    cmd = ":edit";
  }
  {
    invocation = "open_leave"; shortcut = "ol"; key = "alt-enter"; apply_to = "text_file";
    cmd = ":edit";
    leave_broot = true;
  }
  # Alias open_stay with open and add a keybind for it.
  {
    invocation = "open"; shortcut = "o"; key = "ctrl-o";
    cmd = ":open_stay";
  }
  # Add alternate binds for open_leave
  {
    key = "alt-o";
    cmd = ":open_leave";
    leave_broot = true;
  }

  # SHELL COMMAND
  {
    invocation = "shell {cmd}"; shortcut = "sh";
    external = ["sh" "-ce" "{cmd}" ];
  }

  # ZOXIDE+BASH INTEGRATION (requires server mode to be on with --listen flag)
  {
    invocation = "zoxide {dir}"; shortcut = "z"; key = "ctrl-z";
    external = [ "sh" "-ce" "broot --send {server-name} -c \":focus $(zoxide query {dir} --exclude {root})\"" ];
    auto_exec = false; switch_terminal = false;
  }
]
