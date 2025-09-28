
# List all mounted filesystems. Three lines emitted per filesystem: device, mount point, options. Works on Linux and
# macOS; options are surrounded by ':', whitespace removed, e.g. ":rw:seclabel:". Read-only flags are normalized to
# ":ro:". FS type on Linux is appended to options, e.g. ":rw:ext4:", this final field is empty ("::") on macOS, which
# already includes the FS type elsewhere in options.
function mounts() {
    mount \
        | sed -E 's#[(),] ?#:#g' \
        | sed -E 's#:read-only:#:ro:#g' \
        | perl -ne 's/^(.*) on (.*?)( type (\S+))? (:.*)$/$1\n$2\n$5$4:/g; print;'
}
