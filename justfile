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
rust-recipe recipe *args:
    just --yes --justfile hank-rust-types/justfile {{ recipe }} {{ args }}

# Generate Rust types
rust-types: (rust-recipe "types" source_directory())

# Clean Rust types
[confirm("Clean rust types?")]
rust-clean: (rust-recipe "clean")

# Commit Rust types
rust-commit: (rust-recipe "commit")

# Publish Rust types
rust-publish version="patch": (rust-recipe "pubslish" version)

# Run a TypeScript recipe (will always pass --yes)
typescript-recipe recipe *args:
    just --yes --justfile hank-typescript-types/justfile {{ recipe }} {{ args }}

# Generate TypeScript types
typescript-types: (typescript-recipe "types" source_directory())

# Clean TypeScript types
[confirm("Clean typescript types?")]
typescript-clean: (typescript-recipe "clean")

# Commit TypeScript types
typescript-commit: (typescript-recipe "commit")

# Publish TypeScript types
typescript-publish version="patch": (typescript-recipe "publish" version)

# Generate all types
types: rust-types typescript-types

# Clean all types
clean: rust-clean typescript-clean

# Commit all types
commit: rust-commit typescript-commit

# Publish all types
publish: rust-publish typescript-publish

# Update submodules to their latest version
update-submodules:
    cd hank-rust-types && git pull
    git add hank-rust-types
    cd hank-rust-types && git pull
    git add hank-typescript-types
    git commit -m "Update submodules"
