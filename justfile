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

rust-types protos="." out="test":
    rm -rf {{ out }}/src/*
    protos="$(find {{ protos }} -iname "*.proto" | xargs)" && \
        protoc --proto_path={{ protos }} \
            --prost_out={{ out }}/src \
            --prost_opt=type_attribute=hank.access_check.AccessCheckChain.AccessCheck="#[derive(serde::Serialize\, serde::Deserialize)]" \
            --prost_opt=type_attribute=hank.access_check.AccessCheckChain.AccessCheck.kind="#[derive(serde::Serialize\, serde::Deserialize)]" \
            --prost_opt=enum_attribute=hank.access_check.AccessCheckChain.AccessCheck.kind='#[serde(rename_all = "snake_case")]' \
            --prost_opt=field_attribute=hank.access_check.AccessCheckChain.AccessCheck.kind='#[serde(flatten)]' \
            --prost-crate_out={{ out }} \
            --prost-crate_opt=gen_crate={{ out }}/Cargo.toml \
            $protos
    cat {{ protos }}/lib.customizations.rs >> {{ out }}/src/lib.rs
