chooser := "grep -v choose | fzf --tmux"
# Display this list of available commands
@list:
    just --justfile "{{ source_file() }}" --list

alias c := choose
# Open an interactive chooser of available commands
[no-exit-message]
@choose:
    just --justfile "{{ source_file() }}" --chooser "{{ chooser }}" --choose 2>/dev/null

alias e := edit
# Edit the justfile
@edit:
    $EDITOR "{{ justfile() }}"

# Run a Rust recipe (will always pass --yes)
_rust-recipe recipe *args:
    just --yes --justfile hank-rust-types/justfile {{ recipe }} {{ args }}

# Run a TypeScript recipe (will always pass --yes)
_typescript-recipe recipe *args:
    just --yes --justfile hank-typescript-types/justfile {{ recipe }} {{ args }}

# Generate Rust types
[group("rust")]
rust-types: (_rust-recipe "types" source_directory())

# Clean Rust types
[group("rust")]
[confirm("Clean rust types?")]
rust-clean: (_rust-recipe "clean")

# Commit Rust types
[group("rust")]
rust-commit: (_rust-recipe "commit")

# Publish Rust types
[group("rust")]
rust-publish version="patch": (_rust-recipe "pubslish" version)

# Generate TypeScript types
[group("typescript")]
typescript-types: (_typescript-recipe "types" source_directory())

# Clean TypeScript types
[group("typescript")]
[confirm("Clean typescript types?")]
typescript-clean: (_typescript-recipe "clean")

# Commit TypeScript types
[group("typescript")]
typescript-commit: (_typescript-recipe "commit")

# Publish TypeScript types
[group("typescript")]
typescript-publish version="patch": (_typescript-recipe "publish" version)

# Generate all types
[group("all")]
types: rust-types typescript-types

# Clean all types
[group("all")]
clean: rust-clean typescript-clean

# Commit all types
[group("all")]
commit: rust-commit typescript-commit

# Publish all types
[group("all")]
publish: rust-publish typescript-publish

# Update all submodules to their latest version
[group("all")]
update-submodules:
    cd hank-rust-types && git pull
    git add hank-rust-types
    cd hank-rust-types && git pull
    git add hank-typescript-types
    git commit -m "Update all submodules"
