red := `tput setaf 1`
normal := `tput sgr0`
bold := `tput bold`
error := bold + red + "ERROR:" + normal
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
rust-commit: && (_rust-recipe "commit")
    git -C hank-rust-types checkout main

# Publish Rust types
[group("rust")]
rust-publish version="patch": (_rust-recipe "publish" version)

# Generate TypeScript types
[group("typescript")]
typescript-types: (_typescript-recipe "types" source_directory())

# Clean TypeScript types
[group("typescript")]
[confirm("Clean typescript types?")]
typescript-clean: (_typescript-recipe "clean")

# Commit TypeScript types
[group("typescript")]
typescript-commit: && (_typescript-recipe "commit")
    git -C hank-typescript-types checkout main

# Publish TypeScript types
[group("typescript")]
typescript-publish version="patch": (_typescript-recipe "publish" version)

# Generate all types
[group("all")]
types: rust-types typescript-types

# Diff all generated types
[group("all")]
diff:
    git submodule foreach git diff

# Clean all types
[group("all")]
clean: rust-clean typescript-clean

# Commit all types
[group("all")]
commit: rust-commit typescript-commit

# Publish all types
[group("all")]
publish version="patch": (rust-publish version) (typescript-publish version)

# Update all submodules to their latest version
[group("all")]
[no-exit-message]
update-submodules:
    @test -z "$(git status --porcelain --ignore-submodules)" \
        || (echo "{{ error }} Working tree not clean" && exit 1)

    git submodule update --recursive --remote --jobs=10
    git add $(git submodule status | grep "^+" | cut -d ' ' -f2) 2>/dev/null

    @[[ -n "$(git status --porcelain)" ]] \
        && git commit -m "Update all submodules" \
        || echo "Nothing to update"
