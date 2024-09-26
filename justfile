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

rust-types:
    just --justfile hank-rust-types/justfile types "{{ source_directory() }}"

[confirm("Clean rust types?")]
rust-clean:
    just --yes --justfile hank-rust-types/justfile clean

typescript-types:
    just --justfile hank-typescript-types/justfile types "{{ source_directory() }}"

[confirm("Clean typescript types?")]
typescript-clean:
    just --yes --justfile hank-typescript-types/justfile clean

types: rust-types typescript-types

clean: rust-clean typescript-clean
