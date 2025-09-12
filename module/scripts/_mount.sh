#!/usr/bin/env bash
readonly home=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

. "${home}/_platform.sh"

# List all mounted filesystems. Three lines emitted per filesystem: device, mount point, options. Works on Linux and
# macOS; options are surrounded by ':', whitespace removed, e.g. ":rw:seclabel:". Read-only flags are normalized to
# ":ro:".
function _mounts() {
    mount \
        | sed -E 's#[(),] ?#:#g' \
        | sed -E 's#:read-only:#:ro:#g' \
        | perl -ne 's/^(.*) on (.*?)( type \S+)? (.*)$/"$1"\n"$2"\n$4/g; print;'
}

function mount_points {
    local mounts=()
    while IFS= read -r line; do
        IFS=' ' read -r mount_dev mount_root <<< "$line"
        printf '"%s" "%s"\n' "$mount_dev" "$mount_root"
    done < <(_mounts)
}
